- [Tokenizers.DotNet](#tokenizersdotnet)
- [Nuget Package list](#nuget-package-list)
- [Requirements](#requirements)
- [Supported functionalities](#supported-functionalities)
- [How to use](#how-to-use)
  - [(1) Install the packages](#1-install-the-packages)
  - [(2) Write the code](#2-write-the-code)
- [How to build](#how-to-build)
  - [Cross-platform build](#cross-platform-build)

# Tokenizers.DotNet

.NET wrapper of HuggingFace [Tokenizers](https://github.com/huggingface/tokenizers) library  

[![Build (Windows-x64)](https://github.com/sappho192/Tokenizers.DotNet/actions/workflows/build_windows-x64.yml/badge.svg)](https://github.com/sappho192/Tokenizers.DotNet/actions/workflows/build_windows-x64.yml)
[![Build (Multi-platform)](https://github.com/sappho192/Tokenizers.DotNet/actions/workflows/docker-image.yml/badge.svg)](https://github.com/sappho192/Tokenizers.DotNet/actions/workflows/docker-image.yml)

# Nuget Package list

| Package                       | main                                                                                                              | Description                     |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| Tokenizers.DotNet             | [![Nuget Tokenizers.DotNet](https://img.shields.io/nuget/v/Tokenizers.DotNet.svg?style=flat)](https://www.nuget.org/packages/Tokenizers.DotNet/)                         | Core library                    |
| Tokenizers.DotNet.runtime.win-x64 | [![Nuget Tokenizers.DotNet.runtime.win-x64](https://img.shields.io/nuget/v/Tokenizers.DotNet.runtime.win-x64.svg?style=flat)](https://www.nuget.org/packages/Tokenizers.DotNet.runtime.win-x64/) | Native bindings for windows x64 |
| Tokenizers.DotNet.runtime.win-arm64 | [![Nuget Tokenizers.DotNet.runtime.win-arm64](https://img.shields.io/nuget/v/Tokenizers.DotNet.runtime.win-arm64.svg?style=flat)](https://www.nuget.org/packages/Tokenizers.DotNet.runtime.win-arm64/) | Native bindings for windows arm64 |
| Tokenizers.DotNet.runtime.linux-x64 | [![Nuget Tokenizers.DotNet.runtime.linux-x64](https://img.shields.io/nuget/v/Tokenizers.DotNet.runtime.linux-x64.svg?style=flat)](https://www.nuget.org/packages/Tokenizers.DotNet.runtime.linux-x64/) | Native bindings for linux x64 |
| Tokenizers.DotNet.runtime.linux-arm64 | [![Nuget Tokenizers.DotNet.runtime.linux-arm64](https://img.shields.io/nuget/v/Tokenizers.DotNet.runtime.linux-arm64.svg?style=flat)](https://www.nuget.org/packages/Tokenizers.DotNet.runtime.linux-arm64/) | Native bindings for linux arm64 |

# Requirements

- .NET 6 or above
- (Build) Latest [Rust](https://www.rust-lang.org/tools/install)

# Supported functionalities

* [X] Download tokenizer files from Hugginface Hub
* [X] Load tokenizer file(`.json`) from local
* [X] Encode string to tokens
* [X] Decode tokens to string

# How to use

## (1) Install the packages

1. From the NuGet, install `Tokenizers.DotNet` package
2. And then, install `Tokenizers.DotNet.runtime.<OS>-<ARCH>` package too (e.a `win-x64` or `linux-arm64`, check Nuget package list above).

## (2) Write the code

Check following example code:

```CSharp
using Tokenizers.DotNet;

// Download skt/kogpt2-base-v2/tokenizer.json from the hub
var hubName = "skt/kogpt2-base-v2";
var filePath = "tokenizer.json";
var fileFullPath = await HuggingFace.GetFileFromHub(hubName, filePath, "deps");
Console.WriteLine($"Downloaded {fileFullPath}");

// Create a tokenizer instance
Tokenizer tokenizer;
try
{
    tokenizer = new Tokenizer(vocabPath: fileFullPath);
}
catch (TokenizerException e)
{
	Console.WriteLine(e.Message);
    return;
}
try
{
    var text = "음, 이제 식사도 해볼까요";
    Console.WriteLine($"Input text: {text}");
    var tokens = tokenizer.Encode(text);
    Console.WriteLine($"Encoded: {string.Join(", ", tokens)}");
    var decoded = tokenizer.Decode(tokens);
    Console.WriteLine($"Decoded: {decoded}");
}
catch (TokenizerException e)
{
    Console.WriteLine(e.Message);
    return;
}
Console.WriteLine($"Version of Tokenizers.DotNet.runtime.win: {tokenizer.GetVersion()}");
Console.WriteLine("--------------------------------------------------");

//// Download openai-community/gpt2 from the hub
hubName = "openai-community/gpt2";
filePath = "tokenizer.json";
fileFullPath = await HuggingFace.GetFileFromHub(hubName, filePath, "deps");

// Create a tokenizer instance
Tokenizer tokenizer2;
try
{
    tokenizer2 = new Tokenizer(vocabPath: fileFullPath);
}
catch (TokenizerException e)
{
    Console.WriteLine(e.Message);
    return;
}
try
{
    var text2 = "i was nervous before the exam, and i had a fever.";
    Console.WriteLine($"Input text: {text2}");
    var tokens2 = tokenizer2.Encode(text2);
    Console.WriteLine($"Encoded: {string.Join(", ", tokens2)}");
    var decoded2 = tokenizer2.Decode(tokens2);
    Console.WriteLine($"Decoded: {decoded2}");
}
catch (TokenizerException e)
{
    Console.WriteLine(e.Message);
    return;
}

Console.WriteLine($"Version of Tokenizers.DotNet.runtime.win: {tokenizer2.GetVersion()}");
Console.ReadKey();
```

# How to build

1. Prepare following stuff:
   1.  Rust build system (`cargo`)
   2.  .NET build system (`dotnet 6.0, 7.0, 8.0, 9.0`)
   3.  PowerShell (Recommend `7.4.2` or above)
2. Bump the version number in `NATIVE_LIB_VERSION.txt`
3. Run `build_all_clean.ps1`
   1. To build `Tokenizers.DotNet.runtime.<OS>` only, run `build_rust.ps1`
   2. To build `Tokenizers.DotNet` only, run `build_dotnet.ps1`

Each build artifacts will be in `nuget` directory.  

## Cross-platform build

You can use Docker to compile this library for Windows x64/arm64 and Linux x64/arm64

Run `update_version.ps1` before running Docker to update the package version.

Windows:
```shell
PS > docker build -f Dockerfile -t ghcr.io/sappho192/tokenizers.dotnet:latest .
PS > docker run -v .\nuget:/out --rm ghcr.io/sappho192/tokenizers.dotnet:latest
```

Linux/MacOS:
```shell
$ docker build -f Dockerfile -t ghcr.io/sappho192/tokenizers.dotnet:latest .
$ docker run -v ./nuget:/out --rm ghcr.io/sappho192/tokenizers.dotnet:latest
```

Built packages will be in the `nuget` folder.
