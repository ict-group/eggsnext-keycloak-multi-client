<#ftl output_format="plainText">
<#assign realm = realmName!msg("companyName")>
<#assign actionLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>
${msg("actionsEmailTitle")}

Ciao,

${msg("actionsIntro")} ${realm}.
${msg("actionsHelp")}

<#if requiredActions?? && requiredActions?size gt 0>
${msg("actionsTitle")}:
<#list requiredActions as action>
- ${msg(action)?has_content?then(msg(action), action)}
</#list>

</#if>
${actionLink}

${msg("linkExpirationText")} ${expirationText}.
${msg("ignoreText")}

--
${msg("companyName")}
${msg("companyEmail")}
${msg("companyWebsite")}
