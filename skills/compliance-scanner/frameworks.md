# Compliance Framework Checklists

## GDPR (EU)
Applies when: scenario processes data from EU users or connects to EU-region services.

Check for:
- [ ] No documented legal basis for processing (consent, legitimate interest, contract)
- [ ] Personal data stored beyond stated retention period (check data stores used)
- [ ] Data transferred to third-party services without adequacy assessment
- [ ] No data minimization — collecting more data than needed
- [ ] No right-to-deletion path (can data be deleted if user requests?)
- [ ] Automated decisions affecting individuals without human review option

## Quebec Law 25 (Canada — Privacy)
Applies when: workspace owner or data subjects are in Quebec.

Check for:
- [ ] No privacy impact assessment for new automation touching personal data
- [ ] Personal data shared with third-party services without documented consent
- [ ] No breach notification path (what happens when the automation fails and data leaks?)
- [ ] Sensitive personal information (health, biometrics, financial) without explicit consent
- [ ] Data transferred outside Quebec/Canada without safeguards

## PCI-DSS (Payments)
Applies when: `touches_payment_data: true` from scenario-reader.

Check for:
- [ ] Payment card data passing through Make.com (should never be stored in Make.com)
- [ ] Webhook receiving payment data without TLS enforcement
- [ ] Payment data logged in execution logs
- [ ] Third-party payment processor not in PCI-DSS scope

## HIPAA (Health — US)
Applies when: `touches_health_data: true` from scenario-reader.

Check for:
- [ ] PHI (Protected Health Information) passing through Make.com without BAA
- [ ] Make.com used as storage for health records
- [ ] Health data sent to services without HIPAA compliance certification
