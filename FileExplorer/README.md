# FileExplorer

**FileExplorer** is an internal Swift Package. It provides the search functions to enumerate the whole specified directory and feedbacks the URLs which have the duplicated file names.

## Usage

You could simply obtain the URLs which file names are duplicated by passing a directory URL.

``` swift
FileExplorer().findDuplicatedFile(at: targetURL) { result in
    switch result {
    case .success(let duplicatedURLs):
        print(duplicatedURLs)
    case .failure(let error):
        print(error)
    }
}
```

You could set the unneeded search files or directories through passing the `ExcludedInfo`.

``` swift
FileExplorer(excludedInfo: ExcludedInfo(fileNames: "File.swift", directories: "file:///home/desktop"))

```