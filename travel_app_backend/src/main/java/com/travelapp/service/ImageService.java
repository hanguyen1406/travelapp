package com.travelapp.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Service
public class ImageService {

    public String fetchImageFromGoogle(String query) {
        try {
            String encodedQuery = URLEncoder.encode(query, StandardCharsets.UTF_8.toString());
            String url = "https://www.google.com/search?q=" + encodedQuery + "&udm=2"; // udm=2 for image search

            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent",
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
            headers.set("ngrok-skip-browser-warning", "true");

            HttpEntity<String> entity = new HttpEntity<>(headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

            if (response.getStatusCode().is2xxSuccessful()) {
                String body = response.getBody();
                if (body != null) {
                    // Regex pattern to capture the image source
                    // Matches: src="https://encrypted-tbn0.gstatic.com/images?q=..."
                    Pattern pattern = Pattern
                            .compile("src=\"(https://encrypted-tbn0\\.gstatic\\.com/images\\?q=[^\"]+)\"");
                    Matcher matcher = pattern.matcher(body);

                    if (matcher.find()) {
                        String imageUrl = matcher.group(1);
                        return imageUrl.replace("&amp;", "&");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
