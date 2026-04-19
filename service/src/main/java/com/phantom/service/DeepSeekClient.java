package com.phantom.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

/**
 * Thin client around the DeepSeek chat completions API.
 * Returns the raw assistant text. Callers are responsible for parsing.
 */
@Slf4j
public class DeepSeekClient {

    private static final String DEEPSEEK_URL = "https://api.deepseek.com/chat/completions";
    private static final String DEFAULT_MODEL = "deepseek-chat";
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private final HttpClient httpClient;

    public DeepSeekClient() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    DeepSeekClient(HttpClient httpClient) {
        this.httpClient = httpClient;
    }

    public boolean isConfigured() {
        return Constants.DEEPSEEK_API_KEY != null && !Constants.DEEPSEEK_API_KEY.isEmpty();
    }

    /**
     * Calls DeepSeek with a single user prompt and returns the assistant text.
     * Throws on transport failures or non-2xx responses.
     */
    public String complete(String systemPrompt, String userPrompt) throws IOException, InterruptedException {
        if (!isConfigured()) {
            throw new IllegalStateException("DEEPSEEK_API_KEY is not set");
        }

        Map<String, Object> systemMsg = new HashMap<>();
        systemMsg.put("role", "system");
        systemMsg.put("content", systemPrompt);

        Map<String, Object> userMsg = new HashMap<>();
        userMsg.put("role", "user");
        userMsg.put("content", userPrompt);

        Map<String, Object> body = new HashMap<>();
        body.put("model", DEFAULT_MODEL);
        body.put("messages", new Object[]{systemMsg, userMsg});
        body.put("temperature", 0.7);
        body.put("response_format", Map.of("type", "json_object"));
        body.put("stream", false);

        String jsonBody = objectMapper.writeValueAsString(body);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(DEEPSEEK_URL))
                .timeout(Duration.ofSeconds(25))
                .header("Authorization", "Bearer " + Constants.DEEPSEEK_API_KEY)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            log.error("DeepSeek error: HTTP {} - {}", response.statusCode(), response.body());
            throw new IOException("DeepSeek call failed: HTTP " + response.statusCode());
        }

        JsonNode json = objectMapper.readTree(response.body());
        JsonNode choices = json.get("choices");
        if (choices == null || !choices.isArray() || choices.isEmpty()) {
            throw new IOException("DeepSeek response missing choices");
        }

        JsonNode message = choices.get(0).get("message");
        if (message == null || !message.has("content")) {
            throw new IOException("DeepSeek response missing message content");
        }

        return message.get("content").asText();
    }
}
