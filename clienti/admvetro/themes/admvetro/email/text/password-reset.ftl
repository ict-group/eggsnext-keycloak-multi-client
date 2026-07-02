<#ftl output_format="plainText">
<#assign realm = realmName!msg("companyName")>
<#assign actionLink = link!"">
<#assign expirationText = "">
<#attempt>
  <#assign expirationText = linkExpirationFormatter(linkExpiration)>
<#recover>
  <#assign expirationText = "">
</#attempt>
${msg("resetTitle")}

Ciao,

${msg("resetIntro")} ${realm}.
${msg("resetHelp")}

${actionLink}

${msg("linkExpirationText")} ${expirationText}.
${msg("ignoreText")}

--
${msg("companyName")}
${msg("companyAddress")}
${msg("companyPhone")}
${msg("companyEmail")}
${msg("companyWebsite")}
