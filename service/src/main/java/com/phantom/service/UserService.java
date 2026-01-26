package com.phantom.service;

import com.phantom.model.entity.UserProfile;
import com.phantom.repository.AppRepository;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

import java.time.Instant;
import java.util.Map;

@Slf4j
public class UserService {
    
    private final AppRepository appRepository;
    
    public UserService(AppRepository appRepository) {
        this.appRepository = appRepository;
    }
    
    public UserProfile getUserProfile(String userId) {
        log.info("Retrieving user profile for userId: {}", userId);
        
        UserProfile profile = appRepository.getUserProfile(userId);
        
        if (profile == null) {
            log.info("User profile not found, creating new profile for userId: {}", userId);
            profile = createNewUserProfile(userId);
            appRepository.saveUserProfile(profile);
        }
        
        return profile;
    }
    
    public UserProfile updateUserProfile(String userId, String timezone, Map<String, Object> settings) {
        log.info("Updating user profile for userId: {}", userId);
        
        UserProfile profile = appRepository.getUserProfile(userId);
        
        if (profile == null) {
            throw new RuntimeException("User profile not found");
        }
        
        if (timezone != null) {
            profile.setTimezone(timezone);
        }
        
        if (settings != null) {
            profile.setSettings(settings);
        }
        
        appRepository.saveUserProfile(profile);
        
        return profile;
    }
    
    public void deleteUserProfile(String userId) {
        log.info("Deleting user profile for userId: {}", userId);
        appRepository.deleteUserProfile(userId);
    }
    
    private UserProfile createNewUserProfile(String userId) {
        UserProfile profile = new UserProfile();
        profile.setPk(Constants.PK_USER_PREFIX + userId);
        profile.setSk(Constants.SK_PROFILE);
        profile.setEntityType(Constants.ENTITY_TYPE_USER_PROFILE);
        profile.setUserId(userId);
        profile.setCreatedAt(Instant.now().toString());
        profile.setPlan(Constants.PLAN_FREE);
        return profile;
    }
}
