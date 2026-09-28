{{config(schema='staging')}}
select  
    to_date(event_date, 'yyyyMMdd') as event_date,
    user_id,
    min(to_timestamp(from_unixtime(event_timestamp / 1000000))) as session_start_time,
    max(to_timestamp(from_unixtime(event_timestamp / 1000000))) as session_end_time,
    max(1) as firebase_activity,
    max(
        case when event_name in ('App_Installed', 'firebase_campaign', 'App_Launched', 'App_Opened', 'session_start', 'user_engagement') then 1 else 0 end
    ) as user_engagement,
    max(
        case when event_name in ('Welcome_Screen_Get_Started_Button_Click', 'Save_Language_Click_Event', 'Mobile_verification_Started', 'Send_OTP_Click_Event', 'Submit_OTP', 'Name_Save_Click_Event', 'Country_Selected', 'Country_selected', 'Signup_Continue_Clicked', 'Login_Completed', 'Onboarding_completed_Step1', 'Onboarding_completed_Step2') then 1 else 0 end
    ) as onboarding_initiated,
    max(
        case when event_name in ('Onboarding_completed', 'Onboarding_Completed', 'FirstTimeOnboardingCompleted') then 1 else 0 end
    ) as onboarding_completed,
    max(
        case when event_name in ('Permission_popup_shown', 'Permission_granted', 'Permission_denied', 'location_permission_prompt_triggered', 'location_permission_allow', 'location_permission_deny', 'gps_flow_step', 'Device_Location_Fetch_Initiated', 'share_location_clicked', 'Device_Location_Fetch_Succeded', 'location_fetch_success', 'location_update_success', 'location_fetch_failed', 'location_fetch_failed_timeout', 'location_update_failure', 'location_fallback_used_ip_based_location', 'location_settings_opened', 'Save_Location_Event', 'Location_Update_Triggered') then 1 else 0 end
    ) as permissions_flow,
    max(
        case when event_name in ('FirstTimeDashboardViewed', 'Dashboard_Viewed', 'Card_Shown', 'Card_Viewed', 'Card_Clicked', 'Weather_Forecast_Viewed', 'Weather_Forecast_Expanded', 'Market_Price_View_All_Click_Event', 'Leaderboard_Activity_Click', 'ad_viewed', 'ad_failed') then 1 else 0 end
    ) as content_viewership,
    max(
        case when event_name in ('Chat_Icon_Clicked', 'FirstQueryAsked', 'Microphone_Click_Event', 'Image_Option_Dialog_Click_Event', 'Send_Record_Audio_Click_Event', 'Input_Capture_Failed', 'Transcription_Success', 'Transcription_Failed', 'Send_Query_Initiated', 'Send_Query', 'question_card_data_Submitted', 'API_Call_Initiated', 'API_Call_Success', 'API_Call_Failed', 'API_Call_Timeout', 'Started_Playing_Response_Audio', 'Stopped_Playing_Response_Audio') then 1 else 0 end
    ) as chat_interaction,
    max(
        case when event_name in ('Answer_Save_Button_Clicked', 'Answer_Share_Button_Clicked', 'Content_Try_Again_Clicked', 'Start_Over_Clicked') then 1 else 0 end
    ) as response_interaction
from    
    {{ ref('firebase_events')}}

{% if is_incremental() %}

    where to_date(event_date, 'yyyyMMdd') > (select max(event_date) - interval 2 days from {{this}})
{% endif %}
group by 1,2;
    