<#ftl output_format="plainText">
<#assign realm = realmName!msg("companyName")>
<#assign resetLink = link!"">
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

${resetLink}

${msg("resetExpiration")} ${expirationText}.

${msg("resetIgnore")}

--
${msg("companyName")}
${msg("companyAddress")}
${msg("companyPhone")}
${msg("companyEmail")}
${msg("companyWebsite")}
