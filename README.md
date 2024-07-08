This a template for a multiplayer lobby system and a LAN server browser in the Godot game engine. <br>
Version 2.0 is a work in progress.


General Structure:

Main is main scene
Main opens the initial mode
The mode loads the nodes necessary for that mode

Connection Sequence:
    Dedicated server opens:
        Has a node in charge of managing all lobbies: LobbyManager
        Has a matchmaker which has access each of the lobbys data
        Dedicated server launches lobbies 
    Lobby: (Each lobby is a separate process)
        Each lobby has a LobbyManager node which connects to the master Lobby Manager on the dedicated server
        Has a Lobby node which controls the actual lobby
    Client:
        Clients connect first to dedicated server 
        They have a matchmaker which connects to the matchmaker on the dedicated server
        Through the matchmaker they select a lobby to join
        They disconnect from the dedicated server and connect to the lobby (The lobby may reject them)
        They have a lobby node that communicates with the lobby node on the lobby
        
Then the lobby starts the game, telling every client connected to it to load the game 
        