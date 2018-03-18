//
//  PrintReportRequest.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/28/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//
/*
 <PrintReportRq>
	<ModuleName>Shipping</ModuleName>
	<ParameterList>
        <ReportParam>
            <Value>95</Value>
            <Name>shipID</Name>
        </ReportParam>
    </ParameterList>
 </PrintReportRq>
*/

import Foundation


class FbiPrintReportRequest : FbiRequest {
    var PrintReportRq : printReportRequestCore
    
    init(moduleName: String, shipId: Int) {
        PrintReportRq = printReportRequestCore(moduleName: moduleName, reportId: String(shipId))
    }
    
}


class printReportRequestCore {
    class ParamList {
        class RptParam {
            var Name: String?
            var Value: String?
            
            init(name: String, value: String) {
                Name = name
                Value = value
            }
        }
        var ReportParam = [RptParam]()
        
        init(id: String) {
            ReportParam.append(RptParam(name: "shipID", value: id))
        }
    }
    
    var ModuleName: String = ""
    var ParameterList: ParamList!
    
    init(moduleName: String, reportId: String) {
        ModuleName = moduleName
        ParameterList = ParamList(id: reportId)
    }
}
