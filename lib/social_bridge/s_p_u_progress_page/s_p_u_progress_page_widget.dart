import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 's_p_u_progress_page_model.dart';
export 's_p_u_progress_page_model.dart';

class SPUProgressPageWidget extends StatefulWidget {
  const SPUProgressPageWidget({super.key});

  static String routeName = 'SPUProgressPage';
  static String routePath = '/sPUProgressPage';

  @override
  State<SPUProgressPageWidget> createState() => _SPUProgressPageWidgetState();
}

class _SPUProgressPageWidgetState extends State<SPUProgressPageWidget> {
  late SPUProgressPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SPUProgressPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SportFeedbackRecord>>(
      stream: querySportFeedbackRecord(),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<SportFeedbackRecord> sPUProgressPageSportFeedbackRecordList =
            snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              title: Text(
                'Analytics',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
              ),
              actions: [],
              centerTitle: true,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: 370.0,
                        height: 230.0,
                        child: FlutterFlowLineChart(
                          data: [
                            FFLineChartData(
                              xData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.fbWorkout)
                                  .toList(),
                              yData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.lvl)
                                  .toList(),
                              settings: LineChartBarData(
                                color: FlutterFlowTheme.of(context).primary,
                                barWidth: 2.0,
                                dotData: FlDotData(show: false),
                              ),
                            )
                          ],
                          chartStylingInfo: ChartStylingInfo(
                            backgroundColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            showGrid: true,
                            borderColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            borderWidth: 1.0,
                          ),
                          axisBounds: AxisBounds(
                            minX: 0.0,
                            minY: 0.0,
                            maxX: 10.0,
                            maxY: 5.0,
                          ),
                          xAxisLabelInfo: AxisLabelInfo(
                            title: 'Workout Count',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 20.0,
                          ),
                          yAxisLabelInfo: AxisLabelInfo(
                            title: 'Workout Feedback',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: 370.0,
                        height: 230.0,
                        child: FlutterFlowLineChart(
                          data: [
                            FFLineChartData(
                              xData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.lvl)
                                  .toList(),
                              yData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.fbExercises)
                                  .toList(),
                              settings: LineChartBarData(
                                color: FlutterFlowTheme.of(context).primary,
                                barWidth: 2.0,
                                dotData: FlDotData(show: false),
                              ),
                            )
                          ],
                          chartStylingInfo: ChartStylingInfo(
                            backgroundColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            showGrid: true,
                            borderColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            borderWidth: 1.0,
                          ),
                          axisBounds: AxisBounds(
                            minX: 0.0,
                            minY: 0.0,
                            maxX: 10.0,
                            maxY: 5.0,
                          ),
                          xAxisLabelInfo: AxisLabelInfo(
                            title: 'Workout Count',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 32.0,
                          ),
                          yAxisLabelInfo: AxisLabelInfo(
                            title: 'Exercise Feedback',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelTextStyle: TextStyle(),
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: 370.0,
                        height: 230.0,
                        child: FlutterFlowLineChart(
                          data: [
                            FFLineChartData(
                              xData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.lvl)
                                  .toList(),
                              yData: sPUProgressPageSportFeedbackRecordList
                                  .map((d) => d.fbMood)
                                  .toList(),
                              settings: LineChartBarData(
                                color: FlutterFlowTheme.of(context).primary,
                                barWidth: 2.0,
                                dotData: FlDotData(show: false),
                              ),
                            )
                          ],
                          chartStylingInfo: ChartStylingInfo(
                            backgroundColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            showGrid: true,
                            borderColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            borderWidth: 1.0,
                          ),
                          axisBounds: AxisBounds(
                            minX: 0.0,
                            minY: 0.0,
                            maxX: 10.0,
                            maxY: 5.0,
                          ),
                          xAxisLabelInfo: AxisLabelInfo(
                            title: 'Workout Count',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 32.0,
                          ),
                          yAxisLabelInfo: AxisLabelInfo(
                            title: 'Mood Feedback',
                            titleTextStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            showLabels: true,
                            labelTextStyle: TextStyle(),
                            labelInterval: 1.0,
                            labelFormatter: LabelFormatter(
                              numberFormat: (val) => formatNumber(
                                val,
                                formatType: FormatType.compact,
                              ),
                            ),
                            reservedSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
