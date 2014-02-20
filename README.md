MyChat
=====

A very simple **Bonjour** based iOS 7 chat application with chat room auto discovery.

Features
=====
- Open and name chat rooms
- Auto-discovery of chat rooms with Bonjour
- Real-time chatting with multiple concurrent users

View Controllers
=====
- `RoomListVC` - Displays list of available and created chat rooms.
- `RoomVC` - Displays conversation of each room.

Todo list
=====
- Typing notification
- Permanent storage of messages

Libraries
=====
- **[DTBonjour](https://github.com/Cocoanetics/DTBonjour)** - Handles Bonjour communication and auto-discovery of chat rooms.
- **[JSMessagesViewController](https://github.com/jessesquires/MessagesTableViewController)** - Handles displaying of messages and conversations received by Bonjour.
