import socket
import json
HOST = 'localhost'  # Standard loopback interface address (localhost)
PORT = 8081        # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    while True:
        """
        data = s.recv(1024)
        if not data:
            break
        data = data.decode('utf-8')
        print(data)
        j =json.loads(data)
        print(j)
        """
        send_data = json.dumps({"objective": {"x": 1, "y": 2}, "constraints": [[{"x": 1}, ">=", 0], [{"y": 1}, ">=", 0] ]}) + "\n"
        s.sendall(bytes(send_data, encoding="utf-8"))
        data = s.recv(1024)
        if not data:
            break
        data = data.decode('utf-8')
        print(data)