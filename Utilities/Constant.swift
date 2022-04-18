//
//  File.swift
//  
//
//  Created by Shubham Arya on 4/5/22.
//

import Foundation
import UniformTypeIdentifiers

struct K {
    static let docsTypes : [UTType] = [UTType("public.text")!,
                                       UTType("com.apple.iwork.pages.pages")!,
                                       UTType("public.data")!,
                                       UTType("public.database")!,
                                       UTType("public.calendar-event")!,
                                       UTType("public.message")!,
                                       UTType("public.presentation")!,
                                       UTType("public.contact")!,
                                       UTType("public.archive")!,
                                       UTType("public.disk-image")!,
                                       UTType("public.plain-text")!,
                                       UTType("public.utf8-plain-text")!,
                                       UTType("public.utf16-plain-text")!,
                                       UTType("public.rtf")!,
                                       UTType("com.apple.ink.inktext")!,
                                       UTType("public.html")!,
                                       UTType("public.xml")!,
                                       UTType("public.source-code")!,
                                       UTType("public.c-source")!,
                                       UTType("com.apple.rez-source")!,
                                       UTType("public.mig-source")!,
                                       UTType("com.apple.symbol-export")!,
                                       UTType("com.apple.applescript.text")!,
                                       UTType("public.object-code")!,
                                       UTType("com.apple.mach-o-binary")!,
                                       UTType("com.apple.pef-binary")!,
                                       UTType("public.directory")!,
                                       UTType("public.folder")!,
                                       UTType("com.apple.package")!,
                                       UTType("com.apple.bundle")!,
                                       UTType("com.adobe.pdf")!,
                                       UTType("com.microsoft.word.doc")!,
                                       UTType("com.allume.stuffit-archive")!,
                                       UTType("org.openxmlformats.wordprocessingml.document")!,
                                       UTType("org.openxmlformats.presentationml.presentation")!,
                                       UTType("com.microsoft.excel.xls")!,
                                       UTType("org.openxmlformats.spreadsheetml.sheet")!
    ]
    
    static let emptyCollectionViewText = "1. Say the commands for the actions you want to perform.\n\n2. Capture or choose an image with text.\n\n3. Vision extracts the text from the image.\n\n4. Text is processed by natural language processing to correct errors.\n\n5. Corrected text is read aloud using a speech synthesizer."
                         
}

