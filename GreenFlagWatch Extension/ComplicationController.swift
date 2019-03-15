//
//  ComplicationController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/22/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import ClockKit
import CoreData

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let coreDataBastard = CoreDataBastard.sharedBastard
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        //var template : CLKComplicationTemplate?
        switch complication.family {
        case .circularSmall:
            let worktemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            worktemplate.imageProvider.tintColor = UIColor.green
            //circularSmallTemplate.line1TextProvider = CLKSimpleTextProvider(text: "GFc", shortText: "GF")
            //circularSmallTemplate.line2TextProvider = CLKSimpleTextProvider(text: "Indianapolis", shortText: "Indy")
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .modularSmall:
            let worktemplate = CLKComplicationTemplateModularSmallSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            worktemplate.imageProvider.tintColor = UIColor.green
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .modularLarge:
            let worktemplate = CLKComplicationTemplateModularLargeStandardBody()
            let nextEvent = coreDataBastard.nextEvent() as Events
            worktemplate.headerTextProvider = CLKSimpleTextProvider(text: (nextEvent.series?.title!)!,shortText: nextEvent.series?.shortTitle!)
            worktemplate.headerTextProvider.tintColor = UIColor.green
            worktemplate.body1TextProvider = CLKSimpleTextProvider(text: nextEvent.title!,shortText: nextEvent.shorttitle!)
            let startlong = coreDataBastard.startDetailLong(event: nextEvent)
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.body2TextProvider = CLKSimpleTextProvider(text: startlong, shortText: startshort)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .utilitarianSmallFlat:
            let worktemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            worktemplate.textProvider = CLKSimpleTextProvider(text: "GF")
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .utilitarianSmall:
            let worktemplate = CLKComplicationTemplateUtilitarianSmallSquare()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .utilitarianLarge:
            let worktemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            //worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let shorttitle = nextEvent.shorttitle
            let startshort = localDate + " " + localTime
            worktemplate.textProvider = CLKSimpleTextProvider(text: shorttitle! + " " + startshort, shortText: shorttitle! + " " + localDate)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .extraLarge:
            let worktemplate = CLKComplicationTemplateExtraLargeSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Extra Large")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .graphicCorner:
            let worktemplate = CLKComplicationTemplateGraphicCornerTextImage()
            //let worktemplate = CLKComplicationTemplateGraphicCornerCircularImage()
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!)
            worktemplate.textProvider = CLKSimpleTextProvider(text: startshort, shortText: localDate)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .graphicCircular:
            let worktemplate = CLKComplicationTemplateGraphicCircularImage()
            worktemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .graphicBezel:
            let worktemplate = CLKComplicationTemplateGraphicBezelCircularText()
            let circulartemplate = CLKComplicationTemplateGraphicCircularImage()
            circulartemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
            worktemplate.circularTemplate = circulartemplate
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let longtitle = nextEvent.title
            let shorttitle = nextEvent.shorttitle
            let startshort = localDate + " " + localTime
            worktemplate.textProvider = CLKSimpleTextProvider(text: longtitle! + " " + startshort, shortText: shorttitle! + " " + startshort)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        case .graphicRectangular:
            let worktemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            let nextEvent = coreDataBastard.nextEvent() as Events
            worktemplate.headerTextProvider = CLKSimpleTextProvider(text: (nextEvent.series?.title!)!,shortText: nextEvent.series?.shortTitle!)
            worktemplate.headerTextProvider.tintColor = UIColor.green
            worktemplate.body1TextProvider = CLKSimpleTextProvider(text: nextEvent.title!,shortText: nextEvent.shorttitle!)
            let startlong = coreDataBastard.startDetailLong(event: nextEvent)
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.body2TextProvider = CLKSimpleTextProvider(text: startlong, shortText: startshort)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: worktemplate)
            handler(timelineEntry)
        default:
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template : CLKComplicationTemplate?
        switch complication.family {
        case .circularSmall:
            let worktemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Circular")!)
            worktemplate.imageProvider.tintColor = UIColor.green
            template = worktemplate
        case .modularSmall:
            let worktemplate = CLKComplicationTemplateModularSmallSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Modular")!)
            worktemplate.imageProvider.tintColor = UIColor.green
            template = worktemplate
        case .modularLarge:
            let worktemplate = CLKComplicationTemplateModularLargeStandardBody()
            let nextEvent = coreDataBastard.nextEvent() as Events
            worktemplate.headerTextProvider = CLKSimpleTextProvider(text: (nextEvent.series?.title!)!,shortText: nextEvent.series?.shortTitle!)
            worktemplate.headerTextProvider.tintColor = UIColor.green
            worktemplate.body1TextProvider = CLKSimpleTextProvider(text: nextEvent.title!,shortText: nextEvent.shorttitle!)
            let startlong = coreDataBastard.startDetailLong(event: nextEvent)
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.body2TextProvider = CLKSimpleTextProvider(text: startlong, shortText: startshort)
            template = worktemplate
        case .utilitarianSmallFlat:
            let worktemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            worktemplate.textProvider = CLKSimpleTextProvider(text: "GF")
            template = worktemplate
        case .utilitarianSmall:
            let worktemplate = CLKComplicationTemplateUtilitarianSmallSquare()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            template = worktemplate
        case .utilitarianLarge:
            let worktemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            //worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Utilitarian")!)
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let shorttitle = nextEvent.shorttitle
            let startshort = localDate + " " + localTime
            worktemplate.textProvider = CLKSimpleTextProvider(text: shorttitle! + " " + startshort, shortText: shorttitle! + " " + localDate)
            template = worktemplate
        case .extraLarge:
            let worktemplate = CLKComplicationTemplateExtraLargeSimpleImage()
            worktemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Complication/Extra Large")!)
            template = worktemplate
        case .graphicCorner:
            let worktemplate = CLKComplicationTemplateGraphicCornerTextImage()
            //let worktemplate = CLKComplicationTemplateGraphicCornerCircularImage()
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!)
            worktemplate.textProvider = CLKSimpleTextProvider(text: startshort, shortText: localDate)
            template = worktemplate
        case .graphicCircular:
            let worktemplate = CLKComplicationTemplateGraphicCircularImage()
            worktemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            template = worktemplate
        case .graphicBezel:
            let worktemplate = CLKComplicationTemplateGraphicBezelCircularText()
            let circulartemplate = CLKComplicationTemplateGraphicCircularImage()
            circulartemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Bezel")!)
            worktemplate.circularTemplate = circulartemplate
            let nextEvent = coreDataBastard.nextEvent() as Events
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let longtitle = nextEvent.title
            let shorttitle = nextEvent.shorttitle
            let startshort = localDate + " " + localTime
            worktemplate.textProvider = CLKSimpleTextProvider(text: longtitle! + " " + startshort, shortText: shorttitle! + " " + startshort)
            template = worktemplate
        case .graphicRectangular:
            let worktemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            let nextEvent = coreDataBastard.nextEvent() as Events
            worktemplate.headerTextProvider = CLKSimpleTextProvider(text: (nextEvent.series?.title!)!,shortText: nextEvent.series?.shortTitle!)
            worktemplate.headerTextProvider.tintColor = UIColor.green
            worktemplate.body1TextProvider = CLKSimpleTextProvider(text: nextEvent.title!,shortText: nextEvent.shorttitle!)
            let startlong = coreDataBastard.startDetailLong(event: nextEvent)
            let (localDate,localTime) = coreDataBastard.startDetailWatch(event: nextEvent)
            let startshort = localDate + " " + localTime
            worktemplate.body2TextProvider = CLKSimpleTextProvider(text: startlong, shortText: startshort)
            template = worktemplate
        default:
            template = nil
        }
        handler(template)
    }
}
