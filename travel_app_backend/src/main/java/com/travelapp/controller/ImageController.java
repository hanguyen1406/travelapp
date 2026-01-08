package com.travelapp.controller;

import com.travelapp.service.ImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/images")
public class ImageController {

    @Autowired
    private ImageService imageService;

    @GetMapping("/search")
    public ResponseEntity<?> searchImage(@RequestParam String query) {
        String imageUrl = imageService.fetchImageFromGoogle(query);
        Map<String, String> response = new HashMap<>();

        if (imageUrl != null) {
            response.put("imageUrl", imageUrl);
            return ResponseEntity.ok(response);
        } else {
            response.put("message", "No image found");
            return ResponseEntity.status(404).body(response);
        }
    }
}
