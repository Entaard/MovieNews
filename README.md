# Project 1 - MovieNews

MovieNews is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#) to view
most recent/top rated movies.

Time spent: 40 hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees an error message when there is a network error.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [x] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in.
- [x] For the large poster, load the low-res image first, switch to high-res when complete.
- [?] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- In the task "Customize the highlight and selection effect of the cell", I tried to:
  + set background color for the selected/deselected cell, but UIColor seems to have bugs: I used 
  UIColor(red: 255, green: 120, blue: 255, alpha: 1) -> the cell background color became all white ??;
    (You can view my code in TableViewController, search for: "Color bug", and uncomment the functions)
  + also, when I tried to edit the 'selection' option of 'Table View Cell' by XCode UI, only options 
    'None' and 'Default' worked.

- When I setup the Tabbar in code, it blocks the subview. You can go to my TableViewController, prepare function, comment
the line 'detailVC.hidesBottomBarWhenPushed = true', and rerun the app. The tabbar now block the bottom part of the detail
view. Is there anyway to set detailview's height automatically so that it is not blocked by the tabbar?

- I used a same data for both TableView and GridView, that results in having to update both views when I load new data 
(althought only one view is visible at a time). Is there any other effective way to implement the switch view function?

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
