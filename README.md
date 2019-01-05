# Todoist API integration libary
**This is a work in progress - there is still a lot to do!**
Please do leave comments and submit PR's - they will be very much appreciated as I am new in using Elm

A module for integrating Elm apps with the todoist API.
The todoist api has two versions, a rest and a sync one.
Currently this package only support the rest api and only some parts of it.
I am planning on developing this package further in the very near future.

## General stuff about Todoist
### API tokens
Almost all queries to the Todoist api requires you to provide an access token.
This token can be found in
https://todoist.com/prefs/integrations
at the very bottom of the page.
**Be careful with this token**, it provides the same amount of access to your todoist data as your password.


## The Rest API (version 8)
The Todoist rest api is documented on 
https://developer.todoist.com/rest/v8/
and the goal of the package is to support all accepted queries described in this documentation.
