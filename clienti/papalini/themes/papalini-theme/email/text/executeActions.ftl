${msg("actionsTitle")}

Ciao,

${msg("actionsIntro")} ${realmName!msg("companyName")}.

<#if requiredActions?? && requiredActions?size gt 0>
${msg("actionsListTitle")}
<#list requiredActions as action>
- ${msg(action)}
</#list>
</#if>

${msg("actionsHelp")}

${link!""}

${msg("actionsExpiration")} ${linkExpirationFormatter(linkExpiration)}.
${msg("actionsIgnore")}

${msg("companyName")}
${msg("companyWebsite")}
