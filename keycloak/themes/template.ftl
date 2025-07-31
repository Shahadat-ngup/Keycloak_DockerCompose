shahadat@carme:~/Keycloak-Docker/keycloak/themes/IPB_custom-theme/login$ cat template.ftl 
<#-- Keycloak 26+ Login Theme: template.ftl -->
<#-- See: https://www.keycloak.org/docs/latest/server_development/#_themes for official docs -->

<#-- Block layout: all login pages should use this as their base with <@layout.main> ... </@layout.main> -->
<#macro main>
<!DOCTYPE html>
<html lang="${(locale.currentLanguageTag)!'en'}">
<head>
    <meta charset="utf-8">
    <title>
        <#if pageTitle??>${pageTitle}<#else>${msg("loginTitle")}</#if>
    </title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <#if properties.stylesCommon??>
        <link rel="stylesheet" href="${url.resourcesPath}/css/${properties.stylesCommon}">
    </#if>
    <#if properties.styles??>
        <link rel="stylesheet" href="${url.resourcesPath}/css/${properties.styles}">
    </#if>
    <#if properties.favicon??>
        <link rel="icon" href="${url.resourcesPath}/img/${properties.favicon}" />
    </#if>
</head>
<body>
    <div id="kc-container" class="kc-container">
        <div id="kc-container-wrapper" class="kc-container-wrapper">
            <#-- Header: Only show logo if present, no realm name or title -->
            <header>
                <#if properties.logo??>
                    <img src="${url.resourcesPath}/img/${properties.logo}" alt="Logo" class="kc-logo"/>
                </#if>
                <!-- No realm.displayName, realm.name, or loginTitle here -->
            </header>
            <main>
                <#-- Show any global messages (errors, info, etc.) -->
                <#if message?? && message.summary?has_content>
                    <div class="alert <#if message.type??>alert-${message.type?lower_case}</#if>">
                        ${message.summary}
                    </div>
                </#if>
                <#-- Page-specific content will be inserted here by child templates -->
                <#nested>
            </main>
            <footer>
                <#if properties.footerText??>
                    <p>${properties.footerText}</p>
                <#else>
                    <p>&copy; ${.now?string("yyyy")} Keycloak</p>
                </#if>
            </footer>
        </div>
    </div>
</body>
</html>
</#macro>
