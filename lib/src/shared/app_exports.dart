library;

export 'package:private_deals/src/shared/widgets/app_date_time_picker.dart';

///THEME

///ROUTES
export 'package:private_deals/src/app/routing/pages.dart';
export 'package:private_deals/src/app/routing/routes.dart';
export 'package:private_deals/src/shared/theme/app_theme.dart';
export 'package:private_deals/src/shared/theme/app_tokens.dart';
export 'package:private_deals/src/shared/theme/app_motion.dart';
export 'package:private_deals/src/shared/theme/brand_colors.dart';
export 'package:private_deals/src/shared/theme/section_accents.dart';

export 'package:animate_do/animate_do.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:circular_menu/circular_menu.dart';

/// BACKEND
export 'package:private_deals/src/features/auth/data/i_auth_api.dart';
export 'package:private_deals/src/features/auth/data/w_auth_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/bank_accounts/mandate_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/channel_partner/channel_partner_api.dart';
export 'package:private_deals/src/core/config/config_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/dashboard/dashboard_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/demat_account/demat_account_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/document/document_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/favorite/favorite_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/inquiry/inquiry_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/kyc/i_kyc_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/kyc/w_kyc_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/landing_page/landing_page_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/landing_page/unlisted_landing_page_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/live_pitch/live_pitch_api.dart';
export 'package:private_deals/src/core/config/master_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/mis/mis_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/my_earning/my_earning_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/my_family/my_family_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/notification/notification_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/pending_task/pending_task_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/portfolio/portfolio_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/i_pre_ipo_transaction_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/i_primary_transaction_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/i_secondary_transaction_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_pre_ipo_transaction_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_primary_transaction_api.dart';
export 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_secondary_transaction_api.dart';
export 'package:private_deals/src/features/investors/data/w_investors_api.dart';

/// Config
export 'package:private_deals/src/core/session/auth_session.dart';
export 'package:private_deals/src/core/configuration/connectivity_config.dart';
export 'package:private_deals/src/core/configuration/dio_config.dart';
export 'package:private_deals/src/core/configuration/init_config.dart';
export 'package:private_deals/src/core/configuration/notification_config.dart';
export 'package:private_deals/src/core/configuration/pref_config.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/bank_account/bank_account_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/bank_account/mandate_model.dart';

/// MODEL
export 'package:private_deals/src/shared/models/base_model.dart';
export 'package:private_deals/src/shared/models/config_model.dart';
export 'package:private_deals/src/shared/models/enums.dart';
export 'package:private_deals/src/shared/models/master_type_model.dart';
export 'package:private_deals/src/shared/models/media_model.dart';
export 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/dashboard/i_dashboard_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/dashboard/w_dashboard_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/document/document_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/e_kyc/e_kyc_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/earning/investor_earning_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/earning/partner_earning_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/favorite/favorite_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/landing/blog_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/landing/landing_page_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/live_pitch/live_pitch_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/mis/mis_list_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/mis/mis_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/mis/w_mis_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/notification/notification_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/pending_task/pending_task_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/portfolio/portfolio_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/portfolio/pre_ipo_portfolio_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/pre_ipo_landing_page_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/pre_ipo_sell_transaction_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/pre_ipo_transaction_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/sector/sector_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/startup/company_statup_list.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/startup/pitch_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_detail_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_round_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/enquiry_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/primary_transaction_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/secondary_opportunities_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/secondary_transaction_list_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/secondary_transaction_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/transaction/sell_request_model.dart';
export 'package:private_deals/src/features/wealth_manager/data/models/user/aif_model.dart';
export 'package:private_deals/src/features/investors/data/investor_model.dart';
export 'package:private_deals/src/features/investors/data/w_investor_model.dart';
export 'package:private_deals/src/core/session/partner_user.dart';
export 'package:private_deals/src/shared/translation/translation.dart';

/// CONST
export 'package:private_deals/src/shared/constant/app_assets.dart';
export 'package:private_deals/src/shared/constant/app_colors.dart';
export 'package:private_deals/src/core/config/app_key.dart';
export 'package:private_deals/src/core/config/api_endpoints.dart';
export 'package:private_deals/src/shared/constant/app_validator.dart';
// EXTENSION
export 'package:private_deals/src/shared/extensions/date_extensions.dart';
export 'package:private_deals/src/shared/extensions/duration_extensions.dart';
export 'package:private_deals/src/shared/extensions/list_extendtions.dart';
export 'package:private_deals/src/shared/extensions/num_extensions.dart';
export 'package:private_deals/src/shared/extensions/string_extensions.dart';
export 'package:private_deals/src/shared/functions/dialog.dart';
export 'package:private_deals/src/shared/functions/platform_helper.dart';
export 'package:private_deals/src/shared/plugins/cache_image.dart';
export 'package:private_deals/src/shared/plugins/desktop_notification.dart';
export 'package:private_deals/src/shared/plugins/dotted_borders.dart';
// FUNCTION
export 'package:private_deals/src/shared/plugins/download_file/download_file.dart';
export 'package:private_deals/src/shared/plugins/file_picker.dart';
export 'package:private_deals/src/shared/plugins/loader.dart';

///utils
export 'package:private_deals/src/shared/plugins/logger.dart';
export 'package:private_deals/src/shared/plugins/lottie_image.dart';
export 'package:private_deals/src/shared/plugins/luncher.dart';
export 'package:private_deals/src/shared/plugins/otp_text_field.dart';
export 'package:private_deals/src/shared/plugins/pdf_viewer.dart';
export 'package:private_deals/src/shared/plugins/svg_image.dart';
export 'package:private_deals/src/shared/plugins/toast.dart';
export 'package:private_deals/src/shared/plugins/video_player.dart';
export 'package:private_deals/src/shared/widgets/buttons/custom_elevated_button.dart';
export 'package:private_deals/src/shared/widgets/buttons/custom_like_button.dart';
export 'package:private_deals/src/shared/widgets/buttons/custom_outlined_button.dart';
export 'package:private_deals/src/shared/widgets/buttons/custom_text_button.dart';
export 'package:private_deals/src/shared/widgets/buttons/download_button.dart';
export 'package:private_deals/src/shared/widgets/buttons/tab_button.dart';
export 'package:private_deals/src/shared/widgets/clickable.dart';
export 'package:private_deals/src/shared/widgets/fade_in.dart';
export 'package:private_deals/src/shared/widgets/company_deal_card.dart';
export 'package:private_deals/src/shared/widgets/auth_background.dart';
export 'package:private_deals/src/shared/widgets/custom_card_widget.dart';
export 'package:private_deals/src/shared/widgets/custom_drop_down.dart';

/// COMMON WIDGETS
export 'package:private_deals/src/shared/widgets/custom_text_field.dart';
export 'package:private_deals/src/shared/widgets/dialog_widget/delete_dialog_widget.dart';
export 'package:private_deals/src/shared/widgets/dialog_widget/force_update_dialog.dart';
export 'package:private_deals/src/shared/widgets/dialog_widget/logout_dialog.dart';
export 'package:private_deals/src/shared/widgets/gradient_text.dart';
export 'package:private_deals/src/shared/widgets/heading_text.dart';
export 'package:private_deals/src/shared/widgets/investor_chip.dart';
export 'package:private_deals/src/shared/widgets/metric_card.dart';
export 'package:private_deals/src/shared/widgets/no_data_view.dart';
export 'package:private_deals/src/shared/widgets/error_view.dart';
export 'package:private_deals/src/shared/widgets/deal_section_header.dart';
export 'package:private_deals/src/shared/widgets/searchable_text_field.dart';
export 'package:private_deals/src/shared/widgets/status_pipeline.dart';
export 'package:private_deals/src/shared/widgets/title_text.dart';
export 'package:desktop_drop/desktop_drop.dart';
export 'package:file_picker/file_picker.dart';

/// PACKAGES
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_speed_dial/flutter_speed_dial.dart';
export 'package:flutter_stepindicator/flutter_stepindicator.dart';
export 'package:flutter_web_plugins/url_strategy.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:get/get.dart' hide Response, FormData, MultipartFile;
export 'package:google_fonts/google_fonts.dart';
export 'package:percent_indicator/percent_indicator.dart';
export 'package:showcaseview/showcaseview.dart' hide TooltipPosition;
export 'package:syncfusion_flutter_charts/charts.dart';
export 'package:syncfusion_flutter_charts/sparkcharts.dart';
export 'package:visibility_detector/visibility_detector.dart';
