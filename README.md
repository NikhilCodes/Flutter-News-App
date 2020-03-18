# College News/Blog Template
A News/Blog template with sleek UI and Firebase as its backend.

## Features
 - Great UI/UX
 - Caching of Images
 - Firebase as Backend
 - Fair bit of animations
 
## Designing Firestore Database yourself?
### Structure
```
news-articles <type: collection> {
    hsd283y8hh823 <type: document> {
        title: "Some Title 1",
        sub-title: "Some Sub-title",  // Optional
        image-url: "http(s)?://someurl"
        body: "Lorem Ipsum Bla Bla Bla"
        date: "dd MONTH yyyy",  // Example: 13 FEBRUARY 2020
        time: "hh:mm AM/PM",
        timestamp: 202003171107,
        // Example: 202003171107 for 2020 year 03 month 17 day 
        // and last four digit for time in 24 hour format.
    },
    ijhf872424yu5 <type: document> {
        ...
        ...
    }
}
```

## Demo
![Screen Record](/demo/news_blog_screen.gif)
