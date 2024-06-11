- [Tokenizers.DotNet](#tokenizersdotnet)
- [Nuget Package list](#nuget-package-list)
- [Requirements](#requirements)
- [Supported functionalities](#supported-functionalities)
- [Example](#example)

# Tokenizers.DotNet

.NET wrapper of HuggingFace Tokenizers library

# Nuget Package list

| Package                       | main                                                                                                              | Description                     |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| Tokenizers.DotNet             | ![Nuget Tokenizers.DotNet](https://img.shields.io/nuget/v/Tokenizers.DotNet.svg?style=flat)                         | Core library                    |
| Tokenizers.DotNet.runtime.win | ![Nuget Tokenizers.DotNet.runtime.win](https://img.shields.io/nuget/v/Tokenizers.DotNet.runtime.win.svg?style=flat) | Native bindings for windows x64 |

# Requirements

- .NET 6 or above

# Supported functionalities

* [X] Download tokenizer files from Hugginface Hub
* [X] Load tokenizer file(`.json`) from local
* [X] Decode embeddings to string

# Example

Check following example code:

```CSharp
using Tokenizers.DotNet;

var hubName = "skt/kogpt2-base-v2";
var filePath = "tokenizer.json";
var fileFullPath = await HuggingFace.GetFileFromHub(hubName, filePath, "deps");
Console.WriteLine($"Downloaded {fileFullPath}");

// Write the path of tokenizer.json to tokenizer.path.txt
var tokenizerPath = "tokenizer.path.txt";
await File.WriteAllTextAsync(tokenizerPath, fileFullPath);
Console.WriteLine($"Wrote {fileFullPath} to {tokenizerPath}");

// Create a tokenizer instance
var tokenizer = new Tokenizer();
var tokens = new uint[] { 9330, 387, 12857, 9376, 18649, 9098, 7656, 6969, 8084, 1 };
var decoded = tokenizer.Decode(tokens);
Console.WriteLine($"Decoded: {decoded}");
```
