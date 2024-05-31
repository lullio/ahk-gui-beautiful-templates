; * LER ARQUIVO DE CONFIGURAÇÃO E EXIBIR A LISTA DE QUADROS NA LISTVIEW

ReadIniFile:
   Gui Submit, NoHide
   /*
    Autenticação oAuth 2.0
    1. Acessar o Google Cloud Plataform e no projeto habilitar a api tag manager v2
    2. Gerar autenticação oauth 2.0 no projeto e copiar clientid e clientsecret

   */
   clientId := "469887641674-8ourejn84lk7pimu99mnurdsi1nb3n7e.apps.googleusercontent.com"
   clientSecret := "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"
   scope := "https://www.googleapis.com/auth/analytics.readonly"

   ; * INFORMATION API
   ; IniRead, OutputVar, Filename, Section, Key , Default
   ; Client ID
   IniRead, clientID, %iniPath%, APIAuthentication, clientID, 1081190519224-5phvua4dsvqoktp1a4sqlgk35n3s5odv.apps.googleusercontent.com
   GuiControl, ConfigFile:Text, ClientID, %clientID%
   ; Client Secret
   IniRead, clientSecret, %iniPath%, APIAuthentication, clientSecret, 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
   GuiControl, ConfigFile:Text, ClientSecret, %clientSecret%
   ; API Scope
   IniRead, scope, %iniPath%, APIAuthentication, scope, https://www.googleapis.com/auth/analytics.readonly 
   GuiControl, ConfigFile:Text, Scope, %scope%

   ; Código de autorização
   IniRead, authorizedCode, %iniPath%, APIAfterAuthentication, authorizedCode, nada
   GuiControl, ConfigFile:Text, AuthorizedCode, %authorizedCode%
   ; Token de Acesso
   IniRead, accessToken, %iniPath%, APIAfterAuthentication, accessToken, nada
   GuiControl, ConfigFile:Text, AccessToken, %accessToken%
   ; Token de Renovação
   IniRead, refreshToken, %iniPath%, APIAfterAuthentication, refreshToken, nada
   GuiControl, ConfigFile:Text, RefreshToken, %refreshToken%
   ; Código verificador
   IniRead, codigoVerificador, %iniPath%, APIAfterAuthentication, codigoVerificador,
   GuiControl, ConfigFile:Text, CodigoVerificador, %codigoVerificador%
   ; Run %iniPath%
Return

; * ESCREVER NO ARQUIVO DE CONFIGURAÇÃO
SaveToIniFile:
   Gui Submit ; esconder
   ; msgbox % iniPath
   ; msgbox % appdata
   If(!FileExist(iniPath))
   {
      FileCreateDir, %appdata% ; criar a pasta
      FileAppend, "" ,iniPath ; criar o arquivo caso ñ exista
   }
   ; * INFORMATION API
   IniWrite, %ClientID%, %iniPath%, APIAuthentication, clientID
   ; Client Secret
   IniWrite, %ClientSecret%, %iniPath%, APIAuthentication, clientSecret
   ; API Scope
   IniWrite, %Scope%, %iniPath%, APIAuthentication, scope

   ; Código de autorização
   IniWrite, %AuthorizedCode%, %iniPath%, APIAfterAuthentication, authorizedCode
   ; Token de Acesso
   IniWrite, %AccessToken%, %iniPath%, APIAfterAuthentication, accessToken
   ; Token de Renovação
   IniWrite, %RefreshToken%, %iniPath%, APIAfterAuthentication, refreshToken
   ; Codigo verificador
   IniWrite, %CodigoVerificador%, %iniPath%, APIAfterAuthentication, codigoVerificador

   MsgBox, 4160 , Sucesso!, Configurações atualizadas!, 5
   Run %iniPath%
   Gosub, ReadIniFile
Return





GenerateCodeVerifier() {
   ; Implementar a geração de um code_verifier aleatório
   ; Aqui você pode usar uma função para gerar uma sequência aleatória conforme necessário
   ; Exemplo simples:
   Random, rand, 10000000, 99999999
   codeVerifier := "code_verifier_" rand
   return codeVerifier
}
; Isso aqui para conseguir o authcode
GetAccessToken(clientId, clientSecret, scope) {
   Gui Submit, NoHide
   if !InStr(A_OSVersion, "10.")
      appdata := A_ScriptDir
   else
      appdata := A_AppData "\" regexreplace(A_ScriptName, "\.\w+"), isWin10 := true
   iniPath = %appdata%\settings.ini
   ; Passo 1: Gerar o code_verifier
   codeVerifier := GenerateCodeVerifier()
   CodigoVerificador := codeVerifier
   ; Codigo verificador
   IniWrite, %CodigoVerificador%, %iniPath%, APIAfterAuthentication, codigoVerificador
   GuiControl, ConfigFile:Text, CodigoVerificador, %codigoVerificador%
   ; Passo 2: Enviar a solicitação para a autorização do usuário
   url := "https://accounts.google.com/o/oauth2/v2/auth"
   url .= "?client_id=" clientId
   url .= "&redirect_uri=http://localhost:8080"
   url .= "&response_type=code"
   url .= "&scope=" scope
   url .= "&code_challenge=" codeVerifier ; O code_challenge será o próprio code_verifier
   url .= "&code_challenge_method=plain" ; Método recomendado
   ; url .= "&code_challenge_method=S256" ; Método recomendado
   Run %url%
   ; Aguardar até que o usuário autorize e forneça o código de autorização
   Sleep, 500 ; Aguarda 1 segundos (ou o tempo necessário para o usuário autorizar)

   Gui +LastFound +OwnDialogs +AlwaysOnTop
   ; Passo 3: Capturar o código de autorização inserido manualmente
   InputBox, authCode, OAuth 2.0 Authorization Code, Please enter the authorization code you received from Google:, , 300, 150
   if (authCode != "") {
      GuiControl,ConfigFile:, AuthorizedCode, saaaaaaaaaaaaaa
      ; Passo 4: Trocar o código de autorização pelo access token
      arrReponseToken := ExchangeAuthorizationCodeForToken(authCode, clientId, clientSecret, codeVerifier)
      accessToken := arrReponseToken[1]
      return accessToken
   } else {
      MsgBox Autorização cancelada pelo usuário.
      return ""
   }
}

; Depois que inseriu o access Code / Código de verificação / código de acesso
ExchangeAuthorizationCodeForToken(authCode, clientId, clientSecret, codeVerifier) {
   if !InStr(A_OSVersion, "10.")
      appdata := A_ScriptDir
   else
      appdata := A_AppData "\" regexreplace(A_ScriptName, "\.\w+"), isWin10 := true
   iniPath = %appdata%\settings.ini

   ; Passo 5: Trocar o código de autorização pelo access token
   url := "https://oauth2.googleapis.com/token"
   body := "code=" authCode
   body .= "&client_id=" clientId
   body .= "&client_secret=" clientSecret
   body .= "&redirect_uri=http://localhost:8080"
   body .= "&code_verifier=" codeVerifier
   body .= "&grant_type=authorization_code"

   ; Enviar a solicitação POST para trocar o código de autorização pelo access token
   httpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   httpRequest.Open("POST", url, false)
   httpRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   httpRequest.Send(body)

   ; Verificar a resposta
   if (httpRequest.Status == 200) {
      ; Response
      responseBody := httpRequest.ResponseText
      ; msgbox sucesso
      ; msgbox % responseBody
      responseObj := json_toobj(responseBody) ; converter o responseText para um objeto JSON

      ; Recuperar accessToken da Response
      accessToken := responseObj.access_token
      refreshToken := responseObj.refresh_token

      IniWrite, %accessToken%, %iniPath%, APIAfterAuthentication, accessToken
      IniWrite, %refreshToken%, %iniPath%, APIAfterAuthentication, refreshToken
      GuiControl, ConfigFile:Text, AccessToken, %accessToken%
      GuiControl, ConfigFile:Text, RefreshToken, %refreshToken%

      ; msgbox % accessToken
      ; msgbox % refreshToken

      if !IsObject(responseObj) {
         MsgBox Erro ao ler o accessToken
         responseBody := httpRequest.ResponseText
         msgbox % responseBody
         return
      }
      if (accessToken) {
         MsgBox Sucesso, recuperou o accessToken com sucesso
         Clipboard := "verfier: " codeVerifier "`naccessToken: " accessToken "`nreferesh: " refreshToken
         msgbox  % "verfier: " codeVerifier "`naccessToken: " accessToken "`nreferesh: " refreshToken
      } else {
         MsgBox Erro ao obter o access token.
         responseBody := httpRequest.ResponseText
         msgbox % responseBody
         return ""
      }

   } else {
      MsgBox Erro ao trocar o código de autorização pelo access token.
      responseBody := httpRequest.ResponseText
      msgbox % responseBody
      return ""
   }
   Return [accessToken, refreshToken]
}

; Função para atualizar o access token usando o refresh token
RefreshAccessToken(clientId, clientSecret, refreshToken) {
   ; URL e corpo da solicitação para atualizar o access token
   url := "https://oauth2.googleapis.com/token"
   body := "client_id=" clientId
   body .= "&client_secret=" clientSecret
   body .= "&refresh_token=" refreshToken
   body .= "&grant_type=refresh_token"

   ; Enviar a solicitação POST
   httpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   httpRequest.Open("POST", url, false)
   httpRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   httpRequest.Send(body)

   ; Processar a resposta
   if (httpRequest.Status == 200) {
      responseBody := httpRequest.ResponseText
      responseObj := json_toobj(httpRequest.ResponseText)
      newAccessToken := responseObj["access_token"]

      ; Salvar o novo access token no arquivo de configurações
      appdata := InStr(A_OSVersion, "10.") ? A_AppData "\" regexreplace(A_ScriptName, "\.\w+") : A_ScriptDir
      iniPath := appdata "\settings.ini"
      IniWrite, % newAccessToken, % iniPath, APIAfterAuthentication, accessToken

      ; Atualizar a GUI com o novo access token
      GuiControl,ConfigFile:Text, AccessToken, % newAccessToken


      ; Retornar o novo access token
      return newAccessToken
   } else {
      MsgBox, 16,, Erro ao atualizar o access token.
      return ""
   }
}

; Função para validar o access token e decidir os próximos passos
ValidateAndRenewToken(clientId, clientSecret, scope:="https://www.googleapis.com/auth/analytics.readonly") {
   ; Carregar o access token e o refresh token do arquivo de configurações
   appdata := InStr(A_OSVersion, "10.") ? A_AppData "\" regexreplace(A_ScriptName, "\.\w+") : A_ScriptDir
   iniPath := appdata "\settings.ini"
   IniRead, accessToken, %iniPath%, APIAfterAuthentication, accessToken
   IniRead, refreshToken, %iniPath%, APIAfterAuthentication, refreshToken

   ; msgbox % IsAccessTokenValid(accessToken)
   ; Verificar se o access token é válido
   if (IsAccessTokenValid(accessToken)) {
      ; GoSub, RecuperarContasEContainers
      return true
   } else {
      ; Se o token não for válido, tentar atualizar usando o refresh token
      newAccessToken := RefreshAccessToken(clientId, clientSecret, refreshToken)
      ; na função acima, tem o iniwrite para sobreescrever o token
      ; msgbox % newAccessToken
      if (newAccessToken) {
         ; Se conseguir um novo access token, exibir a GUI
            ; Token de Acesso
         ; IniWrite, %newAccessToken%, %iniPath%, APIAfterAuthentication, accessToken
         ; msgbox % newAccessToken
         GoSub, ReadIniFile
         ; GoSub, RecuperarContasEContainers
         return newAccessToken
      } else {
         ; Se não conseguir um novo access token, iniciar o fluxo de autorização
         accessToken := GetAccessToken(clientId, clientSecret, scope)
         return accessToken
      }
   }
}

; Função para verificar se o access token é válido
IsAccessTokenValid(accessToken) {
   ; Enviar uma solicitação GET para um endpoint que requer autenticação
   url := "https://www.googleapis.com/oauth2/v1/tokeninfo"
   httpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   httpRequest.Open("GET", url "?access_token=" accessToken, false)
   httpRequest.Send()

   ; Se a resposta for bem-sucedida, o token é válido
   ; return (httpRequest.ResponseText)
   return (httpRequest.Status == 200)
}