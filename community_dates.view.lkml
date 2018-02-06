view: community_dates {
  derived_table: {
    sql: SELECT
      crime_copy.date AS date,
      crime_copy.latitude AS latitude,
      crime_copy.longitude AS longitude,
      COUNT(*) AS crime_copy_count
    FROM chicago_dataset.crime_copy AS crime_copy, (SELECT MAX(foo.crime_copy_count) as Max_Crime, foo.crime_copy_community_area
                                                      FROM(
                                                        SELECT
                                                          crime_copy.community_area AS crime_copy_community_area,
                                                          COUNT(*) AS crime_copy_count
                                                        FROM chicago_dataset.crime_copy  AS crime_copy
                                                        WHERE
                                                          {% condition community_dates.year %} crime_copy.year {% endcondition %} AND
                                                          {% condition community_dates.crime_type %} lOWER(crime_copy.primary_type) {% endcondition %}
                                                        GROUP BY 1
                                                        ORDER BY 2 ASC) as foo
                                                    GROUP BY 2
                                                    ORDER BY 1 DESC
                                                    LIMIT 1) as bar
    WHERE
      {% condition community_dates.year %} crime_copy.year {% endcondition %} AND
      {% condition community_dates.crime_type %} lOWER(crime_copy.primary_type) {% endcondition %}AND
      crime_copy.community_area = bar.crime_copy_community_area
    GROUP BY 1, 2, 3
    ORDER BY 4 ASC
  ;;
  }

  filter: year {
    type: number
  }

  filter: crime_type {
    type: string
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: Bro {
    #label: "Date Bro"
    type: time
    sql: ${TABLE}.date ;;
    convert_tz: no
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: crime_copy_count {
    type: number
    sql: ${TABLE}.crime_copy_count ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  set: detail {
    fields: [latitude, longitude, crime_copy_count, location]
  }
}
