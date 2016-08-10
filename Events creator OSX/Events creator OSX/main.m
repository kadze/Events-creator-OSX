//
//  main.m
//  Events creator OSX
//
//  Created by Andrey on 8/9/16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EventKit/EventKit.h>

static NSString * const kSAPEventTitle = @"Test Event";
static NSUInteger eventsPerCalendarCount = 500;

void SAPCreateEvents(NSUInteger count, EKCalendar *calendar, EKEventStore *store);
EKCalendar *SAPCalendarWithTitle(NSString *title, EKEventStore *store);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        EKEventStore *store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];
        NSArray<EKCalendar *> *calendars = [store calendarsForEntityType:EKEntityTypeEvent];
        
        NSString *title1 = @"Test Events 1";
        NSString *title2 = @"Test Events 2";
        NSArray<NSString *> *titles = @[title1, title2];
        NSMutableArray<NSString *> *titlesToCreate = [titles mutableCopy];
        
        for (EKCalendar *calendar in calendars) {
            NSLog(@"%@; %@; %hhd", calendar.title, calendar.calendarIdentifier, calendar.immutable);
            if ([titles containsObject:calendar.title]) {
                SAPCreateEvents(eventsPerCalendarCount, calendar, store);
                [titlesToCreate removeObject:calendar.title];
            }
        }
        
        for (NSString *title in titlesToCreate) {
            EKCalendar *calendar = SAPCalendarWithTitle(title, store);
//            [store saveCalendar:calendar commit:YES error:nil];
            NSError *error = nil;
            BOOL result = [store saveCalendar:calendar commit:YES error:&error];
            if (result) {
                NSLog(@"Saved calendar %@", calendar.title);
                
                SAPCreateEvents(eventsPerCalendarCount, calendar, store);
            } else {
                NSLog(@"Error saving calendar: %@.", error);
            }
        }

//        EKEventStore *eventStore = [[EKEventStore alloc] init];
//        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"Hello world!!!");
//            });
//        }];
        
        
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *dc = [[NSDateComponents alloc] init];
//        [dc setHour:1];
//        NSDate *startDate = [NSDate date];
//        NSDate *endDate = [calendar dateByAddingComponents:dc toDate:[NSDate date] options:0];
//        EKEvent *anEvent = [EKEvent eventWithEventStore:eventStore];
//        [anEvent setTitle:@"event1"];;
//        [anEvent setCalendar:[[eventStore calendarsForEntityType:EKCalendarTypeLocal]objectAtIndex:0]];
//        [anEvent setLocation:@"Somewhere"];
//        [anEvent setStartDate:startDate];
//        [anEvent setEndDate:endDate];
//        [eventStore saveEvent:anEvent span:EKSpanThisEvent commit:YES error:nil];
    }
    return 0;
}

void SAPCreateEvents(NSUInteger count, EKCalendar *calendar, EKEventStore *store) {
    NSDate *startDate = [NSDate date];
    for (NSUInteger counter = 0; counter < count; counter++) {
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = kSAPEventTitle;
        event.calendar = calendar;
        event.startDate = startDate;
        
        NSCalendar *helpCalendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.hour = 1;
        
        event.endDate = [helpCalendar dateByAddingComponents:dateComponents toDate:startDate options:0];
        
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
        NSLog(@"Saved event %@ for date %@", event.title, startDate);
        
        dateComponents = [NSDateComponents new];
        dateComponents.day = 1;
        startDate = [helpCalendar dateByAddingComponents:dateComponents toDate:startDate options:0];
    }
}

EKCalendar *SAPCalendarWithTitle(NSString *title, EKEventStore *store) {
    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:store];
    calendar.title = title;
    
    EKSource *localSource = nil;
    for (EKSource *source in store.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    
    calendar.source = localSource;
        return calendar;
}