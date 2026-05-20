${msg("executeTitle")}

Ciao<#if user?? && user.firstName??> ${user.firstName}</#if>,

${msg("executeIntro")} ${realmName!"Keycloak"}.

<#if requiredActions?? && requiredActions?size gt 0>
${msg("executeRequiredActions")}
<#list requiredActions as action>
- ${action}
</#list>

</#if>
${msg("executeHelp")}

${link}

${msg("executeExpiration")} ${linkExpiration} ${msg("minutes")}.
${msg("executeIgnore")}

${msg("companyName")}
${msg("resetFooter")}
