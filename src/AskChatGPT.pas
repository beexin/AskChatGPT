(****************************************************************************
                   ..::::..
                :-==-------==-.
              -=-::.........:-==:.....
            .==:............::-==----===-:
           .==:..........::-==-:.......:--=-.
       .:-===:........:--==-:.............:-=:
    .-==-::==:.....:-==--:.....:--::........-=-
   -=-:....==:....==-::....::-==--===-:......-=.
  -=-......==:....==:...:--==-::...:--==-::..-=-
 :=-.......==:....==::-=====-::.......::-==---=-
 ==:.......==:....====-.   .-==-::........:-===-
 ==:.......==:....==.         .-==--:........:-=-
 -=-.......==-:...==           :=--===-:.......:==
  ==::::::::-===-:==           :=-:::-==::::::::-=-
   -=-:::::::::-====.          -=-::::==:::::::::==
    :===-::::::::::-==-:   .:====-::::==:::::::::==
    :=--===--:::::::::-=====-::-=-::::==::::::::-=:
    -=-::::-===-:::::-===-:::::-=-::::==:::::::-=-
    -+-:::::::--======-::::::::-+-::::+=::::::==-
     ==:::::::::::-::::::::::-===:::::+=:::-==-.
     .==:::::::::::::::::-===-::::::::+++==:.
       -+=::::::::::::-=+=-::::::::::-+-
        .-===--:::--===-::::::::::::-+-
           .:--====+=:::::::::::::-=+:
                   :=+=-:::::::-===-
                     .:-==+++==-:.

AskChatGPT™ - ChatGPT API for Delphi

Copyright © 2022-present tinyBigGAMES™ LLC
All Rights Reserved.

Website: https://tinybiggames.com
Email  : support@tinybiggames.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software in
   a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

3. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

4. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

5. All video, audio, graphics and other content accessed through the
   software in this distro is the property of the applicable content owner
   and may be protected by applicable copyright law. This License gives
   Customer no rights to such content, and Company disclaims any liability
   for misuse of content.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*****************************************************************************)

unit AskChatGPT;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.Mime,
  System.JSON,
  WinApi.Windows;

const
  CR   = #13;
  LF   = #10;
  CRLF = CR+LF;
  ENVVAR_APIKEY = 'ChatGPTApiKey';

type
  { TGPTModel }
  TGPTModel = (GPT3, GPT4);

  { TAskChatGPT }
  TAskChatGPT = class
  protected const
    CModel: array[GPT3..GPT4] of string = ('gpt-3.5-turbo', 'gpt-4');
  protected
    FApiKey: string;
    FQuestion: string;
    FResponse: string;
    FModel: TGPTModel;
    function GetEnvVarValue(const aVarName: string): string;
    procedure SetAPIKey(const aValue: string);
    procedure SetQuestion(const aValue: string);
  public
    property ApiKey: string read FApiKey write SetApiKey;
    property Model: TGPTModel read FModel write FModel;
    property Question: string read FQuestion write SEtQuestion;
    property Response: string read FResponse;
    constructor Create; virtual;
    destructor Destroy; override;
    function Process: Boolean;
  end;

implementation

{ TAskChatGPT }
function TAskChatGPT.GetEnvVarValue(const aVarName: string): string;
var
  LBufSize: Integer;  // buffer size required for value
begin
  // Get required buffer size (inc. terminal #0)
  LBufSize := GetEnvironmentVariable(PChar(aVarName), nil, 0);
  if LBufSize > 0 then
  begin
    // Read env var value into result string
    SetLength(Result, LBufSize - 1);
    GetEnvironmentVariable(PChar(aVarName), PChar(Result), LBufSize);
  end
  else
    // No such environment variable
    Result := '';
end;

procedure TAskChatGPT.SetAPIKey(const aValue: string);
begin
  if aValue.IsEmpty then
    // if value is empty try to get api key from environment variable
    FApiKey := GetEnvVarValue(ENVVAR_APIKEY)
  else
    // otherwise set api key to value
    FApiKey := aValue;
end;

procedure TAskChatGPT.SetQuestion(const aValue: string);
var
  LQuestion: string;
begin
  // set question to empty
  LQuestion := '';

  // if value is empty return
  if aValue.IsEmpty then Exit;

  // try to sanitize question
  LQuestion := aValue;

  // trim blanks
  LQuestion := LQuestion.Trim;

  // remove invalid characters
  LQuestion := LQuestion.Replace(#0, ' ');
  LQuestion := LQuestion.Replace(CR, ' ');
  LQuestion := LQuestion.Replace(LF, ' ');

  // save question
  FQuestion := LQuestion;
end;

constructor TAskChatGPT.Create;
begin
  inherited;

  // try to get api key from environment variable
  FApiKey := GetEnvVarValue(ENVVAR_APIKEY);

  // use gpt3 by default
  FModel := GPT3;

  // set default question
  Question := 'What is the Delphi language?';
end;

destructor TAskChatGPT.Destroy;
begin
  inherited;
end;

function TAskChatGPT.Process: Boolean;
var
  LHttpClient: TNetHTTPClient;
  LString: string;
  LJson: TJsonObject;
  LMessages: TJsonArray;
  LMessage: TJsonObject;
  LPostDataStream: TStringStream;
  LResponse: IHTTPResponse;
begin
  Result := False;

  // check if there is an api key present
  if FApiKey.IsEmpty then Exit;

  // check if there is a question present
  if FQuestion.IsEmpty then Exit;

  // set response string to empty
  FResponse := '';

  try
    // create http client
    LHttpClient := TNetHTTPClient.Create(nil);
    try
      // init customer headers
      LHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + FApiKey;
      LHttpClient.CustomHeaders['Content-Type'] := 'application/json';

      // create Json object
      LJson := TJsonObject.Create;
      try

        // create Json message array object
        LMessages := TJsonArray.Create;
        try

          // create Json message object
          LMessage := TJsonObject.Create;
          try
            // set api role
            LMessage.AddPair('role', 'user');

            // set api content
            LMessage.AddPair('content', FQuestion);
            LMessages.Add(LMessage.Clone as TJsonObject);
          finally
            LMessage.Free;
          end;
          // set api model
          LJson.AddPair('model', cModel[FModel]);

          // set api message
          LJson.AddPair('messages', LMessages.Clone as TJsonArray);

          // get Json string
          LString := LJson.ToString;
        finally
          LMessages.Free;
        end;
      finally
        LJson.Free;
      end;

      // create post data stream
      LPostDataStream := TStringStream.Create(LString, TEncoding.UTF8);
      try
        // post data to GPT api and get response string
        LPostDataStream.Position := 0;
        LResponse := LHttpClient.Post('https://api.openai.com/v1/chat/completions', LPostDataStream);
        LString := LResponse.ContentAsString;
      finally
        LPostDataStream.Free;
      end;

      // create Json object from response string
      LJson := TJsonObject.ParseJSONValue(LString) as TJsonObject;
      try
        // if success get response message
        if LResponse.StatusCode = 200 then
          begin
            FResponse := LJson.P['choices[0].message.content'].Value;
          end
        else
          // otherwise get response error
          begin
            if LJSon.FindValue('error.message') <> nil then
              FResponse := 'Error: ' + LJson.P['error.message'].Value
            else
              begin
                FResponse := Format('Error: HTTP response code %d: %s', [LResponse.StatusCode, LResponse.StatusText]);
              end;
          end;
      finally
        // free Json object
        LJson.Free;
      end;
    finally
      // free httpclient object
      LHttpClient.Free;
    end;
  except
    on E: Exception do
      FResponse := Format('Error: %s', [E.Message]);
  end;

  // indicate there was a response
  Result := not FResponse.IsEmpty;
end;

end.
