# Changelog of ActiveAnalytics

## Version 0.4.1 (2025-03-13)

-   Shortened index name in migration to prevent argument error (index name too long)

## Version 0.4.0 (2025-03-06)

-   Record browser statistics from user agent
-   Added `base_controller_class` configuration option to allow specifying a custom base controller for the ActiveAnalytics dashboard,
    enhancing flexibility in diverse application architectures.

## Version 0.3 (2023-09-15)

*   Queue requests to reduce the load on database writes

    Database writes are slow. On large trafic applications it might overload the database.
    The idea is to queue data into redis and to flush periodically into the database.

    ```ruby
    ActiveAnalytics.queue_request(request) # In an after_action
    ```

    Then call from time to time :

    ```ruby
    ActiveAnalytics.flush_queue # From a cron or a job
    ```

*   Deliver CSS and JS without asset pipeline
*   Reverse date range when start is after end
*   Add link to external page
*   Display views evolution against previous period
*   List all paths from a host referrer when available
*   Scope css styles with .active-analytics
*   Update colors to augment contrast
*   Add gap to separate days in chart
*   Add link to day on chart label
*   Prevent chart NaN
*   Add trend labels color
*   Remove unused css
*   Add environment variable ACTIVE_ANALYTICS_REDIS_URL
