![AskChatGPT](media/logo.png)  

[![Chat on Discord](https://img.shields.io/discord/754884471324672040.svg?logo=discord)](https://discord.gg/tPWjMwK) [![Twitter Follow](https://img.shields.io/twitter/follow/tinyBigGAMES?style=social)](https://twitter.com/tinyBigGAMES)
# AskChatGPT 
### ChatGPT API for Delphi

Access OpenAI's **ChatGPT** API from <a href="https://www.embarcadero.com/es/products/delphi" target="_blank">Delphi</a>. 

### Features
- Access GPT API from a single class, simple and easily
- Supports GPT3 and GPT4 models
- Can read API key from `ChatGPTApiKey` environment variable if defined 
- Will attempt to sanitize input to minimize errors

### Coming Features
- Proxy support
- Non-blocking support

### Minimum Requirements 
- Windows 10
- <a href="https://www.embarcadero.com/products/delphi/starter" target="_blank">Delphi Community Edition</a>

### Usage
- Get your API Key:
  https://platform.openai.com/account/api-keys

- Define environment variable `ChatGPTApiKey` and assigned your API key. You may have to reboot your machine for it to take effect.

```Delphi
uses
    AskChatGPT;
    
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
end.
```

### Support
- <a href="https://github.com/tinyBigGAMES/AskChatGPT/issues" target="_blank">Issues</a>
- <a href="https://github.com/tinyBigGAMES/AskChatGPT/discussions" target="_blank">Discussions</a>
- <a href="https://platform.openai.com/docs/introduction" target="_blank">OpenAI API Docs</a>
- <a href="https://tinybiggames.com/" target="_blank">tinyBigGAMES Homepage</a>

<p align="center">
<img src="media/delphi.png" alt="Delphi">
</p>
<h5 align="center">

Made with :heart: for Delphi
</h5>