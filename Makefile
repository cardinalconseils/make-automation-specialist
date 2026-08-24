# Every check in this repo. `make test` is what CI runs — keep them the same.
# smoke-test.sh already invokes test-review-gate.sh, so it is not listed twice.

# The .make/ output dirs are gitignored runtime state, so a fresh checkout (and
# every CI run) lacks them and smoke-test.sh fails 14 checks. Scaffold them from
# plugin.json — the same source smoke-test-checks.sh reads — so there is one list.
.PHONY: scaffold
scaffold:
	@python3 -c "import json;d=json.load(open('plugin.json'));r=d.get('output',{}).get('root','.make');print('\n'.join(r+'/'+x for x in d.get('output',{}).get('directories',[])))" \
	  | xargs -I{} mkdir -p {}

.PHONY: test
test: scaffold
	@bash scripts/smoke-test.sh
	@bash scripts/test-make-sdk.sh
