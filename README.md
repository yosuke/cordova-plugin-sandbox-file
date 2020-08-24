---
title: File
description: Read/write files in the iOS sandbox.
---
<!--
# license: Licensed to the Apache Software Foundation (ASF) under one
#         or more contributor license agreements.  See the NOTICE file
#         distributed with this work for additional information
#         regarding copyright ownership.  The ASF licenses this file
#         to you under the Apache License, Version 2.0 (the
#         "License"); you may not use this file except in compliance
#         with the License.  You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#         Unless required by applicable law or agreed to in writing,
#         software distributed under the License is distributed on an
#         "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#         KIND, either express or implied.  See the License for the
#         specific language governing permissions and limitations
#         under the License.
-->

# cordova-plugin-sandbox-file

This plugin calls `startAccessingSecurityScopedResource` iOS API before reading the file to be used in conjunction with iOS File app.

## Usage

Add following lines to your config.xml.
Be sure to customize UTTypeIdentifier and UTTypeTagSpecification to define your own filename extension:

```xml
<config-file parent="LSSupportsOpeningDocumentsInPlace" platform="ios" target="*-Info.plist">
    <true />
</config-file>
<config-file parent="UIFileSharingEnabled" platform="ios" target="*-Info.plist">
    <true />
</config-file>
<config-file parent="UTExportedTypeDeclarations" platform="ios" target="*-Info.plist">
    <array>
        <dict>
            <key>CFBundleTypeIconFiles</key>
            <array></array>
            <key>UTTypeDescription</key>
            <string>Sample Project File</string>
            <key>UTTypeIdentifier</key>
            <string>sampleproject.ext</string>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.data</string>
            </array>
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <string>ext</string>
                <key>public.mime-type</key>
                <string>application/x-example-project</string>
            </dict>
        </dict>
    </array>
</config-file>
<config-file parent="CFBundleDocumentTypes" platform="ios" target="*-Info.plist">
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Sample Project File</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>sampleproject.ext</string>
            </array>
        </dict>
    </array>
</config-file>
```

Write your application code:

```javascript
window.handleSandboxFile = (url, data) => {
  // Add your code here. data is in ByteArray format.
};
```

handleSandboxFile function should be fired after you select your file on iOS File app.

## Supported Platforms

- iOS

## License

Apache-2.0

Copyright 2020 Yosuke Matsusaka
