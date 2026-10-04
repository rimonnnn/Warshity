import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/loading_widget.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/clients/presentation/cubit/debt_cubit.dart';
import 'package:warshity/features/clients/presentation/cubit/remove_clients_cubit.dart';
import 'package:warshity/features/clients/presentation/widgets/remove_client_dialog.dart';
import 'package:warshity/features/clients/presentation/widgets/customer_map_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/decrease_debt_dialog.dart';
import 'package:warshity/features/clients_details/presentation/widgets/invoice_list.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';

part '../widgets/web_customers_state.dart';
part '../widgets/web_customers_header.dart';
part '../widgets/web_customers_card.dart';
part '../widgets/web_customers_toolbar.dart';
part '../widgets/web_customers_table.dart';
part '../widgets/web_customers_table_row.dart';
part '../widgets/web_customer_details.dart';
part '../widgets/web_customer_details_widgets.dart';
part '../widgets/web_customer_states.dart';
class WebCustomers extends StatefulWidget {
  const WebCustomers({super.key});

  @override
  State<WebCustomers> createState() => _WebCustomersState();
}