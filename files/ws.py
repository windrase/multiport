#!/usr/bin/env python3
import select
import socket
import sys
import threading
import time

LISTENING_ADDR = '127.0.0.1'
LISTENING_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 10015
PASS = ''
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:143'
RESPONSE = b'HTTP/1.1 101 WINTUNELINGVPN\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: foo\r\n\r\n'


class Server(threading.Thread):
    def __init__(self, host, port):
        super().__init__()
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threads_lock = threading.Lock()
        self.log_lock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, int(self.port)))
        self.soc.listen(128)
        self.running = True
        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(True)
                except socket.timeout:
                    continue
                conn = ConnectionHandler(c, self, addr)
                conn.start()
                self.add_conn(conn)
        finally:
            self.running = False
            self.soc.close()

    def print_log(self, log):
        with self.log_lock:
            print(log)

    def add_conn(self, conn):
        with self.threads_lock:
            if self.running:
                self.threads.append(conn)

    def remove_conn(self, conn):
        with self.threads_lock:
            if conn in self.threads:
                self.threads.remove(conn)

    def close(self):
        self.running = False
        with self.threads_lock:
            for c in list(self.threads):
                c.close()


class ConnectionHandler(threading.Thread):
    def __init__(self, soc_client, server, addr):
        super().__init__()
        self.client_closed = False
        self.target_closed = True
        self.client = soc_client
        self.client_buffer = b''
        self.server = server
        self.log = 'Connection: ' + str(addr)

    def close(self):
        try:
            if not self.client_closed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except Exception:
            pass
        self.client_closed = True

        try:
            if not self.target_closed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except Exception:
            pass
        self.target_closed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
            host_port = self.find_header(self.client_buffer, 'X-Real-Host') or DEFAULT_HOST
            split = self.find_header(self.client_buffer, 'X-Split')
            if split:
                self.client.recv(BUFLEN)

            passwd = self.find_header(self.client_buffer, 'X-Pass')
            if PASS and passwd != PASS:
                self.client.sendall(b'HTTP/1.1 400 WrongPass!\r\n\r\n')
                return

            if host_port.startswith('127.0.0.1') or host_port.startswith('localhost'):
                self.method_connect(host_port)
            else:
                self.client.sendall(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
        except Exception as e:
            self.log += f' - error: {e}'
            self.server.print_log(self.log)
        finally:
            self.close()
            self.server.remove_conn(self)

    @staticmethod
    def find_header(head_bytes, header):
        head = head_bytes.decode('utf-8', 'ignore')
        marker = f'{header}: '
        idx = head.find(marker)
        if idx == -1:
            return ''
        data = head[idx + len(marker):]
        end = data.find('\r\n')
        return '' if end == -1 else data[:end]

    def connect_target(self, host):
        if ':' in host:
            h, p = host.rsplit(':', 1)
            host, port = h, int(p)
        else:
            port = 443
        family, socktype, proto, _, address = socket.getaddrinfo(host, port)[0]
        self.target = socket.socket(family, socktype, proto)
        self.target_closed = False
        self.target.connect(address)

    def method_connect(self, path):
        self.log += ' - CONNECT ' + path
        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.server.print_log(self.log)
        self.do_connect()

    def do_connect(self):
        sockets = [self.client, self.target]
        count = 0
        while True:
            count += 1
            recv, _, err = select.select(sockets, [], sockets, 3)
            if err or count >= TIMEOUT:
                break
            for src in recv:
                try:
                    data = src.recv(BUFLEN)
                    if not data:
                        return
                    dst = self.client if src is self.target else self.target
                    dst.sendall(data)
                    count = 0
                except Exception:
                    return


def main():
    print(f'Listening on {LISTENING_ADDR}:{LISTENING_PORT}')
    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print('Stopping...')
            server.close()
            break


if __name__ == '__main__':
    main()