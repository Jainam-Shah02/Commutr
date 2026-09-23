package com.commutr.backend;

import com.commutr.backend.dto.BusPositionDto;
import com.commutr.backend.websocket.BusPositionWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.time.Instant;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class WebSocketIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private BusPositionWebSocketHandler webSocketHandler;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("WebSocket client should connect and receive real-time bus position broadcasts")
    void testWebSocketBroadcast() throws Exception {
        BlockingQueue<String> receivedMessages = new ArrayBlockingQueue<>(5);

        StandardWebSocketClient client = new StandardWebSocketClient();
        WebSocketSession session = client.execute(new TextWebSocketHandler() {
            @Override
            protected void handleTextMessage(WebSocketSession s, TextMessage message) {
                receivedMessages.offer(message.getPayload());
            }
        }, "ws://localhost:" + port + "/ws/bus-positions").get(5, TimeUnit.SECONDS);

        assertTrue(session.isOpen());

        // Broadcast a position
        BusPositionDto dto = new BusPositionDto(
                1L, 1L, 19.1932, 72.9692, 28.0, 110.0, 4.0, 3, "LOW", Instant.now(), true
        );
        webSocketHandler.broadcast(dto);

        // Wait for message
        String payload = receivedMessages.poll(5, TimeUnit.SECONDS);
        assertNotNull(payload, "Client should receive broadcasted message");
        assertTrue(payload.contains("\"busId\":1"));
        assertTrue(payload.contains("19.1932"));

        session.close();
    }
}
