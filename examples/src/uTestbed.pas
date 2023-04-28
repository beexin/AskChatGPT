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

unit uTestbed;

interface

procedure RunTests;

implementation

uses
  System.SysUtils,
  System.Classes,
  AskChatGPT,
  uUtils;

procedure Test01;
var
  LChat: TAskChatGPT;
begin
  LChat := TAskChatGPT.Create;
  try
    // check if we get API, by default it will take from ChatGPT env var
    if LChat.ApiKey.IsEmpty then
      PrintLn('ApiKey was not Found', [])
    else
      PrintLn('ApiKey: %s', [LChat.ApiKey]);
  finally
    LChat.Free;
  end;

  Pause;
end;

procedure Test02;
var
  LChat: TAskChatGPT;
begin
  LChat := TAskChatGPT.Create;
  try
    // process and print response using defaults:
    // apikey   - will try to read from environment variable `ChatGPTApiKey`
    // question - What is the Delphi language?

    // print question
    PrintLn('Q: %s', [LChat.Question]);

    if LChat.Process then
      PrintLn('A: %s', [LChat.Response]);
  finally
    LChat.Free;
  end;

  Pause;
end;

procedure Test03;
var
  LChat: TAskChatGPT;
  LQuestion: TStringList;
begin
  LQuestion := TStringList.Create;
  try
    // ask a question (will have CR and LF, they should get removed)
    LQuestion.Add('Make a routine in Delphi ');
    LQuestion.Add('');  // add blank line
    LQuestion.Add('that will remove all duplicates ');
    LQuestion.Add(#0); // add invalid char
    LQuestion.Add('from a unicode string');

    LChat := TAskChatGPT.Create;
    try
      // set the GPT model
      LChat.Model := GPT3;

      // invalid chars should be removed
      LChat.Question := LQuestion.Text;

      // print question
      PrintLn('Q: %s', [LChat.Question]);

      // process and print response
      if LChat.Process then
        PrintLn('A: %s', [LChat.Response]);
    finally
      LChat.Free;
    end;
  finally
    LQuestion.Free;
  end;

  Pause;
end;

procedure Test04;
begin

end;

procedure RunTests;
begin
  //Test01;
  //Test02;
  Test03;
end;

end.
