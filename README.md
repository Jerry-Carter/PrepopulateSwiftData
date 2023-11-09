# How to Prepopulate a SwiftData Database for Inclusion as a Client Resource

## Overview

Suppose you have a large database covering the greatest hits of 20th century music.  You'd like to include this with your iOS MusicMania application.  You could always download the entire thing when the application first launches, but wouldn't it be much better to simply include it with your application in the first place?

## Step 1: Build a SwiftData database

I've included a command line tool which extracts data from a PostgreSQL database and copies this into SwiftData.  If you already have built a SwiftData database, you can skip to the next step.  **NOTE: The code will compile but will not run as the PostgreSQL username, password, etc. will not match your architecture.  If you like the idea of a command line tool, this will get you started but the details are necessarily left to you.**

`ClientDatabaseBuilder <path>`

The code appears in the `Sources/Builder` directory.  In summary, it

* deletes any old files at the indicated path
* connects to the master database (here I use PostgreSQL)
* prepares SwiftData to save to the given path
* queries the master database and writes rows into SwiftData

At the end of this process, the data that you've selected will be stored in an SQLite database -- this is the backing behind SwiftData.  Unfortunately, a [Write-Ahead Log](https://www.sqlite.org/wal.html) is created which will need to be cleared.

## Step 2: Compact the SQLite database

A second command line tool is employed to empty the Write-Ahead Log and perform a vacuum operation which, theoretically, reduces the file size.  After this process, the SwiftData database will be ready for incorporating into the client as a resource.

`SQLiteCompactor <path>`

Simply point this at any SQLite database and it will work it's magic.  As the SQLite documentation notes, *"Usually, the WAL file is deleted automatically when the last connection to the database closes."*  This does not appear to happen with SwiftData. *"The only safe way to remove a WAL file is to open the database file...[and]...then immediately close the database."*  In this case, experience has shown that an additional `vacuum` operation is needed to clear the WAL file.  Don't worry, `SQLiteCompactor` takes care of everything.

## Step 3: Incorporate the SQLite database as a resource file

As clients vary considerably, no sample code is provided.  Conceptually, the project will need to include the database as a resource and then configure SwiftData to access the include resource.

Paul Hudson of [Hacking With Swift](https://www.hackingwithswift.com) has a good [write-up for iOS](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-pre-populate-an-app-with-an-existing-swiftdata-database) which I recommend. 