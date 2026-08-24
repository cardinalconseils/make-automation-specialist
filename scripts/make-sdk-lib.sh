# shellcheck shell=bash
# Pull/push loops for make-sdk.sh (sourced). Pristine copies live in <app>/.orig/
# so push only writes sections you actually changed.

SECTIONS="api parameters expect interface samples scope"
# Make stores IML sections as JSON-with-comments. Override if the API rejects it.
SECTION_CT="${MAKE_SDK_CONTENT_TYPE:-application/jsonc}"

die() { printf '\033[31merror:\033[0m %s\n' "$1" >&2; exit 1; }

# api <method> <path> [body-file] [content-type] -> sets API_BODY, returns 2xx status
api() {
  local method="$1" path="$2" data="${3:-}" ct="${4:-application/json}" resp
  if [ -n "$data" ]; then
    resp=$(curl -sS -w '\n%{http_code}' -X "$method" "$BASE_URL$path" \
      -H "Authorization: Token $MAKE_API_KEY" -H "Content-Type: $ct" --data-binary "@$data")
  else
    resp=$(curl -sS -w '\n%{http_code}' -X "$method" "$BASE_URL$path" \
      -H "Authorization: Token $MAKE_API_KEY")
  fi
  API_CODE="${resp##*$'\n'}"
  API_BODY="${resp%$'\n'*}"
  case "$API_CODE" in 2??) return 0 ;; esac
  return 1
}

# Fail with a plain-language message instead of a raw HTTP code.
explain() {
  case "$API_CODE" in
    401) die "Make rejected the token (401). Check MAKE_API_KEY in .env." ;;
    403) die "Token lacks SDK scopes (403). Add sdk-apps:read and sdk-apps:write." ;;
    404) die "Not found (404): $1. Check the app name, version, and MAKE_ZONE=$MAKE_ZONE." ;;
    *)   die "Make returned HTTP $API_CODE for $1: $API_BODY" ;;
  esac
}

cmd_apps() {
  api GET "/sdk/apps" || explain "/sdk/apps"
  printf '%s\n' "$API_BODY" | jq -r '
    (.apps // .sdkApps // .) as $a
    | if ($a | length) == 0 then "No custom apps in this account."
      else ($a[] | "\(.name)\tv\(.version // 1)\t\(.label // "")") end'
}

cmd_pull() {
  local app="$1" ver="$2" dir mods m s dest
  dir="$ROOT/.make/apps/$app"
  mkdir -p "$dir/general" "$dir/.orig/general"

  api GET "/sdk/apps/$app/$ver/base" || explain "app base"
  printf '%s\n' "$API_BODY" > "$dir/general/base.imljson"
  cp "$dir/general/base.imljson" "$dir/.orig/general/base.imljson"

  api GET "/sdk/apps/$app/$ver/modules" || explain "module list"
  mods=$(printf '%s\n' "$API_BODY" | jq -r '(.appModules // .modules // .) | .[].name')

  for m in $mods; do
    mkdir -p "$dir/modules/$m" "$dir/.orig/modules/$m"
    for s in $SECTIONS; do
      # Not every module type has every section; a 404 here is expected, not an error.
      if api GET "/sdk/apps/$app/$ver/modules/$m/$s"; then
        dest="$dir/modules/$m/$s.imljson"
        printf '%s\n' "$API_BODY" > "$dest"
        cp "$dest" "$dir/.orig/modules/$m/$s.imljson"
      fi
    done
    printf '  pulled module %s\n' "$m"
  done

  jq -n --arg a "$app" --arg v "$ver" --arg z "$MAKE_ZONE" \
    '{app:$a, version:$v, zone:$z, origins:[{appId:$a, appVersion:$v, baseUrl:("https://"+$z+".make.com/api/v2")}]}' \
    > "$dir/makecomapp.json"
  printf '\nPulled %s v%s -> .make/apps/%s/\n' "$app" "$ver" "$app"
}

cmd_push() {
  local app="$1" ver="$2" dir f rel orig n=0
  dir="$ROOT/.make/apps/$app"
  [ -d "$dir" ] || die "No local copy at .make/apps/$app — run 'pull' first."

  while IFS= read -r f; do
    rel="${f#"$dir"/}"
    orig="$dir/.orig/$rel"
    [ -f "$orig" ] && cmp -s "$f" "$orig" && continue
    n=$((n + 1))
    if [ "$DRY_RUN" = 1 ]; then printf '  would push %s\n' "$rel"; continue; fi
    if [ "$rel" = "general/base.imljson" ]; then
      printf '  \033[33mnote:\033[0m base only supports PATCH (deep merge) — deleting a key locally will NOT delete it on Make.\n'
      api PATCH "/sdk/apps/$app/$ver/base" "$f" "$SECTION_CT" || explain "$rel"
    else
      api PUT "/sdk/apps/$app/$ver/${rel%.imljson}" "$f" "$SECTION_CT" || explain "$rel"
    fi
    mkdir -p "$(dirname "$orig")"; cp "$f" "$orig"
    printf '  pushed %s\n' "$rel"
  done < <(find "$dir" -path "$dir/.orig" -prune -o -name '*.imljson' -print | sort)

  [ "$n" = 0 ] && { printf 'Nothing changed — local matches Make.\n'; return 0; }
  [ "$DRY_RUN" = 1 ] && printf '\n%s section(s) would be pushed. Re-run without --dry-run.\n' "$n"
  return 0
}
