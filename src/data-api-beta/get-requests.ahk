GetUsers(accessToken) {
   ; Configurações
   ; msgbox % accessToken
   url := "https://analyticsdata.googleapis.com/v1beta/properties/358422628:runReport"

   ; ! as variáveis abaixo estão no arquivo json/get-users.json
   ; Define os campos obrigatórios
   view_id := "358422628" ; Substitua pelo ID da sua vista (propriedade)
   start_date := "2024-01-01"
   end_date := "2024-03-30"

   ; Cria o objeto de solicitação
   request_body := "json/get-users.json"
   FileRead, request_body, %request_body%
   Transform, request_body, deref, % request_body
   ; msgbox % request_body

   ; request_body := json_toobj(request_body)

   ; Faz a solicitação para obter dados
   httpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   httpRequest.Open("POST", url, false)
   httpRequest.SetRequestHeader("Authorization", "Bearer " accessToken)
   httpRequest.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
   httpRequest.Send(request_body)

   ; Verifica a resposta
   if (httpRequest.Status == 200) {
       responseBody := httpRequest.ResponseText
       ; Exibe a resposta (pode ser necessário analisar o JSON)
       MsgBox % responseBody
       return responseBody
   } else {
       MsgBox Erro ao obter dados do Google Analytics.
       MsgBox % httpRequest.ResponseText
       return ""
   }
}