package com.phantom.service;

import com.phantom.model.entity.DashboardSummary;
import com.phantom.repository.AppRepository;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DashboardService {
    
    private final AppRepository appRepository;
    
    public DashboardService(AppRepository appRepository) {
        this.appRepository = appRepository;
    }
    
    public DashboardSummary getDashboardSummary(String userId) {
        log.info("Retrieving dashboard summary for userId: {}", userId);
        
        DashboardSummary summary = appRepository.getDashboardSummary(userId);
        
        if (summary == null) {
            log.info("Dashboard summary not found, creating empty summary for userId: {}", userId);
            summary = createEmptyDashboardSummary(userId);
            appRepository.saveDashboardSummary(summary);
        }
        
        return summary;
    }
    
    private DashboardSummary createEmptyDashboardSummary(String userId) {
        DashboardSummary summary = new DashboardSummary();
        summary.setPk(Constants.PK_USER_PREFIX + userId);
        summary.setSk(Constants.SK_DASHBOARD_SUMMARY);
        summary.setEntityType(Constants.ENTITY_TYPE_DASH_SUMMARY);
        summary.setGhostCountTotal(0);
        summary.setGhostCount30d(0);
        summary.setStreakDays(0);
        return summary;
    }
}
