This a template for a multiplayer lobby system and a LAN server browser in the Godot game engine. <br>
Version 2.0 is a work in progress.<br><br><br>
General Structure:

Main is main scene <br>
Main opens the initial mode<br>
The mode loads the nodes necessary for that mode<br>
<br>
Connection Sequence:<br>
    Dedicated server opens:<br>
        Has a node in charge of managing all lobbies: LobbyManager<br>
        Has a matchmaker which has access each of the lobbys data <br>
        Dedicated server launches lobbies <br>
    Lobby: (Each lobby is a separate process) <br>
        Each lobby has a LobbyManager node which connects to the master Lobby Manager on the dedicated server <br> 
        Has a Lobby node which controls the actual lobby <br>
    Client: <br>
        Clients connect first to dedicated server <br>
        They have a matchmaker which connects to the matchmaker on the dedicated server <br>
        Through the matchmaker they select a lobby to join <br>
        They disconnect from the dedicated server and connect to the lobby (The lobby may reject them) <br>
        They have a lobby node that communicates with the lobby node on the lobby <br>       
<br>
Then the lobby starts the game, telling every client connected to it to load the game 
        