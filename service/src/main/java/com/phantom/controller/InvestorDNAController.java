package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.service.InvestorDNAService;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@Slf4j
public class InvestorDNAController {

    private final InvestorDNAService investorDNAService;

    public InvestorDNAController(InvestorDNAService investorDNAService) {
        this.investorDNAService = investorDNAService;
    }

    public APIGatewayV2HTTPResponse getInvestorDNA(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Map<String, Object> profile = investorDNAService.generateProfile(userId);
            return ResponseBuilder.ok(profile);
        } catch (Exception e) {
            log.error("Error generating investor DNA profile", e);
            return ResponseBuilder.internalServerError("Failed to generate Investor DNA profile");
        }
    }
}
