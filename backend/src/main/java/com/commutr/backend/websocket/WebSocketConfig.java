package com.commutr.backend.websocket;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final BusPositionWebSocketHandler busPositionWebSocketHandler;

    public WebSocketConfig(BusPositionWebSocketHandler busPositionWebSocketHandler) {
        this.busPositionWebSocketHandler = busPositionWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(busPositionWebSocketHandler, "/ws/bus-positions")
                .setAllowedOrigins("*");
    }
}
