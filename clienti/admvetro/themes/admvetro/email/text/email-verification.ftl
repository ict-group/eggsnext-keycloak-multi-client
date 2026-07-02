<#ftl output_format="plainText">
<#assign realm = realmName!msg("companyName")>
<#assign actionLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>
${msg("verifyTitle")}

Ciao,

${msg("verifyIntro")} ${realm}.
${msg("verifyHelp")}

${actionLink}

${msg("linkExpirationText")} ${expirationText}.
${msg("ignoreText")}

--
${msg("companyName")}
${msg("companyEmail")}
${msg("companyWebsite")}
