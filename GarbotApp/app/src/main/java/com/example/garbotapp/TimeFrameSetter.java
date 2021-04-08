package com.example.garbotapp;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

// This class gets a timestamp and can return a time or a date based on it
public class TimeFrameSetter {

    private final int SECONDS_IN_HOUR = 3600;
    private final long SECONDS_IN_WEEK = 604800;
    private final long SECONDS_IN_MONTH = 2628000;
    private final long SECONDS_IN_YEAR = 31540000;
    private ArrayList<Integer> types;
    private ArrayList<String> timeFrames;

    public TimeFrameSetter() {
    }

    // Determines if a time or date should be returned and does so accordingly
    public void setTimeFrames(ArrayList<Integer> types, ArrayList<Long> timestamps) {
        this.types = types;
        this.timeFrames = new ArrayList<>();
        ZoneId zoneId = getTimezoneID();
        ZonedDateTime currentZonedTime = ZonedDateTime.now(zoneId);
        int currentHour = currentZonedTime.getHour();
        Date date = new Date();
        long currentTime = (date.getTime() / 1000);
        long timeLastDay = currentTime - (SECONDS_IN_HOUR * currentHour);
        long timeLastWeek = currentTime - SECONDS_IN_WEEK;
        long timeLastMonth = currentTime - SECONDS_IN_MONTH;
        long timeLastYear = currentTime - SECONDS_IN_YEAR;

        for (long timestamp : timestamps) {
            if (timeLastDay < timestamp) {
                timeFrames.add("Day"); // within current day
            } else if (timeLastWeek < timestamp) {
                timeFrames.add("Week"); // within past week
            } else if (timeLastMonth < timestamp) {
                timeFrames.add("Month"); // within past month
            } else if (timeLastYear < timestamp) {
                timeFrames.add("Year"); // within past year
            } else {
                timeFrames.add("None");
            }
        }
    }

    // Gets count of garbage in given time frame
    public int getGarbage(String type) {
        int count = 0;

        for (int x = 0; x < types.size(); x ++) {
            if (types.get(x) == 0 && timeFrames.get(x).equals(type)) { // 0 represents garbage
                count ++;
            }
        }

        return count;
    }

    // Gets count of garbage in given time frame
    public int getCompost(String type) {
        int count = 0;

        for (int x = 0; x < types.size(); x ++) {
            if (types.get(x) == 1 && timeFrames.get(x).equals(type)) { // 1 represents compost
                count ++;
            }
        }

        return count;
    }

    // Gets count of garbage in given time frame
    public int getPaper(String type) {
        int count = 0;

        for (int x = 0; x <types.size(); x ++) {
            if (types.get(x) == 2 && timeFrames.get(x).equals(type)) { // 2 represents paper
                count ++;
            }
        }

        return count;
    }

    // Gets count of garbage in given time frame
    public int getRecycling(String type) {
        int count = 0;

        for (int x = 0; x < types.size(); x ++) {
            if (types.get(x) == 3 && timeFrames.get(x).equals(type)) { // 3 represents recycling
                count ++;
            }
        }

        return count;
    }

    // Gets the timezone id
    private ZoneId getTimezoneID() {
        Calendar cal = Calendar.getInstance();
        long milliDiff = cal.get(Calendar.ZONE_OFFSET);

        // Got local offset, now loop through available timezone id(s).
        String [] ids = TimeZone.getAvailableIDs();
        for (String id : ids) {
            TimeZone tz = TimeZone.getTimeZone(id);
            if (tz.getRawOffset() == milliDiff) {
                return ZoneId.of(id);
            }
        }

        return ZoneId.of("Pacific Standard Time");
    }
}
