# Define the header of the HTML file
$htmlHeader = @"
<!DOCTYPE html>
<html>
<head>
    <title>HSC Mathematics Resources</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            color: #212529;
            margin: 0;
        }
        .container {
            max-width: 960px;
            margin: 0 auto;
            padding: 20px;
        }
        #search-input {
            width: 100%;
            padding: 12px 20px;
            margin-bottom: 20px;
            box-sizing: border-box;
            border: 1px solid #ced4da;
            border-radius: .25rem;
            font-size: 1rem;
        }
        .folder-structure {
            background-color: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: .25rem;
            padding: 20px;
            box-shadow: 0 .125rem .25rem rgba(0,0,0,.075);
        }
        h1 {
            font-size: 2rem;
            margin-bottom: 1.5rem;
            font-weight: 300;
        }
        .folder {
            margin-left: 25px;
        }
        .folder-name {
            font-weight: 500;
            cursor: pointer;
            padding: 8px 0;
            display: flex;
            align-items: center;
            transition: background-color 0.2s ease-in-out;
        }
        .folder-name:hover {
            background-color: #e9ecef;
        }
        .folder-name i {
            margin-right: 12px;
            color: #495057;
            transition: transform 0.2s ease-in-out;
        }
        .folder-name.open > i {
            transform: rotate(90deg);
        }
        .folder-contents {
            display: none;
            padding-left: 25px;
            border-left: 1px solid #ced4da;
        }
        .file a {
            text-decoration: none;
            color: #007bff;
            display: flex;
            align-items: center;
            padding: 8px 0;
            transition: background-color 0.2s ease-in-out;
        }
        .file a:hover {
            background-color: #e9ecef;
            text-decoration: none;
        }
        .file i {
            margin-right: 12px;
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>HSC Mathematics Resources</h1>
        <input type="text" id="search-input" placeholder="Search for files and folders...">
        <div class="folder-structure">
"@

# Define the footer of the HTML file
$htmlFooter = @"
        </div>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', (event) => {
            const folderNames = document.querySelectorAll('.folder-name');
            folderNames.forEach(name => {
                name.addEventListener('click', event => {
                    const folderContents = name.nextElementSibling;
                    if (folderContents && folderContents.classList.contains('folder-contents')) {
                        folderContents.style.display = folderContents.style.display === 'block' ? 'none' : 'block';
                        name.classList.toggle('open');
                    }
                });
            });

            const searchInput = document.getElementById('search-input');
            searchInput.addEventListener('keyup', event => {
                const searchTerm = event.target.value.toLowerCase();
                const files = document.querySelectorAll('.file');
                const folders = document.querySelectorAll('.folder');

                files.forEach(file => {
                    const fileName = file.textContent.toLowerCase();
                    if (fileName.includes(searchTerm)) {
                        file.style.display = 'block';
                    } else {
                        file.style.display = 'none';
                    }
                });

                folders.forEach(folder => {
                    const folderName = folder.querySelector('.folder-name').textContent.toLowerCase();
                    const folderContents = folder.querySelector('.folder-contents');
                    const filesInFolder = folderContents.querySelectorAll('.file');
                    let hasVisibleFile = false;
                    filesInFolder.forEach(file => {
                        if (file.style.display !== 'none') {
                            hasVisibleFile = true;
                        }
                    });

                    if (folderName.includes(searchTerm) || hasVisibleFile) {
                        folder.style.display = 'block';
                    } else {
                        folder.style.display = 'none';
                    }
                });
            });
        });
    </script>
</body>
</html>
"@

# Function to generate the HTML for the directory structure
function Get-DirectoryHtml {
    param (
        [string]$Path,
        [string]$RelativePath
    )

    $html = ""
    # Sort so that folders are always on top, then files, both alphabetically
    $items = Get-ChildItem -Path $Path | Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

    foreach ($item in $items) {
        $currentRelativePath = "$RelativePath/$($item.Name)"
        if ($item.PSIsContainer) {
            # Ignore .git and Schools directories
            if ($item.Name -eq ".git" -or $item.Name -eq "Schools") {
                continue
            }
            $html += "<div class=`"folder`">"
            $html += "<div class=`"folder-name`"><i class=`"fas fa-folder`"></i> $($item.Name)</div>"
            $html += "<div class=`"folder-contents`">"
            $html += Get-DirectoryHtml -Path $item.FullName -RelativePath $currentRelativePath
            $html += "</div>"
            $html += "</div>"
        } else {
            if ($item.Extension -eq ".pdf") {
                $html += "<div class=`"file`">"
                $html += "<a href=`"$currentRelativePath`" target=`"_blank`"><i class=`"fas fa-file-pdf`"></i> $($item.Name)</a>"
                $html += "</div>"
            }
        }
    }

    return $html
}

# Start generating the HTML from the root directory
$directoryHtml = Get-DirectoryHtml -Path (Get-Location) -RelativePath ""

# Combine header, body, and footer
$finalHtml = $htmlHeader + $directoryHtml + $htmlFooter

# Write the final HTML to index.html
$finalHtml | Out-File -FilePath "index.html" -Encoding utf8

Write-Host "index.html generated successfully."
