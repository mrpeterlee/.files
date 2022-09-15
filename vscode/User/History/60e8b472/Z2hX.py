"""
id:            Peter Lee (peter.lee@astrocapital.net)
last_update:   2022-Sep-13 12:12:38
type:          lib
sensitivity:   datalab@astrocapital.net
platform:      any
description:   Strategy Template - Master Seafood 

This strategy utilizes minutely level data and intend to profit from mean-reversion.

TODO
====
    - [ ] Make algo run daily - Consoidator issue
"""

# region imports

from datetime import timedelta
from typing import List

import finclab.lean.portfolio.stats
import pandas as pd
from AlgorithmImports import *
from config import StratConfig
from finclab.lean.util.install_attributes import install_attributes
from finclab.logger import init_logger
from munch import Munch

from ts.execution.master_squid import MasterSquid
from ts.portfolio.master_crayfish import MasterCrayfish
from ts.universe.master_clam import MasterClam

# endregion

# Note cyrpto coarse available: https://www.quantconnect.com/forum/discussion/13612/crypto-coarse-universe-selection-is-now-available/p1


class MasterSeafood(QCAlgorithm):
    """This strat is about an awesome master seafood kungfu."""

    name = "Strat MasterSeafood"

    def Initialize(self):

        self.logger = init_logger(name=self.name, indent=0, color="yellow")

        # Override the symbol reference file
        # source: /Lean/Data/symbol-properties/symbol-properties-database.csv
        # Target:
        self.logger.critical("Overriding symbol reference file...")
        from glob import iglob

        level2 = iglob("/LeanCLI/*/*")
        for i in level2:
            self.logger.critical(f"{i}")

        # Backtest: Start Date and End Date
        self.SetStartDate(2022, 1, 1)
        self.SetEndDate(2022, 1, 10)

        # Backtest: Portfolio's cash to begin with
        self.SetCash(100000)

        # Store strategy parameters in the dict `params` in a way that is compatible with lean optimizer
        self.config = Munch()
        for name, default in StratConfig.items():
            if isinstance(default, (str, float, int)) and str(default).isnumeric():
                self.config[name] = pd.to_numeric(self.GetParameter(name, str(default)))
                continue
            self.config[name] = default

        # Create a dict of tickers to store symbol-specific data
        self.symbol_data = Munch()

        # Set benchmark -> QC benchmark makes use of hourly data...
        # self.SetBenchmark("BTCUSD")

        # Set global warm-up time, required a non-zero value for indicators
        self.SetWarmup(1)

        # set cash portion as 5% of portfolio
        self.Settings.FreePortfolioValuePercentage = 0.05

        # Set Brokerage Model
        self.SetBrokerageModel(BrokerageName.Bitfinex, AccountType.Margin)

        # Some live data providers impose data subscription limits, adjust accordingly
        self.Settings.DataSubscriptionLimit = 5000

        # Timmezone settings
        self.SetTimeZone("UTC")

        # =========================== Algorithm Framework =========================== #

        # === 1 - Universe Selection ===
        #     --- Global Settings ---
        #         Data resolution frequency:: Default to Resolution.Minute
        self.UniverseSettings.Resolution = self.config.data_resolution

        #         Extended market hour:: True to allow extended market hours, default to False
        self.UniverseSettings.ExtendedMarketHours = False

        #         Fill forward:: If there is no data point for the current slice, use the prev data point
        self.UniverseSettings.FillForward = True
        #         Minimum time assets in universe, default to 1
        self.UniverseSettings.MinimumTimeInUniverse = timedelta(1)

        #     --- Futures contracts ---
        # What offset from the current front month should be used for continuous Future contracts? 0 uses the front month and 1 uses the back month contract. This setting is only available for Future assets.
        self.UniverseSettings.ContractDepthOffset = 0  # default to 0
        self.UniverseSettings.DataMappingMode = DataMappingMode.OpenInterest
        #     --- Equities & Futures contracts ---
        #     How should historical prices be adjusted
        self.UniverseSettings.DataNormalizationMode = DataNormalizationMode.Adjusted
        #     float, What leverage should assets use in the universe?
        #     This setting is not available for derivative assets.
        self.UniverseSettings.Leverage = Security.NullLeverage

        # Subscribe to these symbol data - Mannual Universe
        _data = [ Symbol.Create(symbol, self.config.security_type, Market.Bitfinex) for symbol in self.config.universe ]
        self.AddUniverseSelection(ManualUniverseSelectionModel(_data))

        # HACK: the below doesn't work for DOODOO. Trying the above
        # self.AddUniverse(
        #     MasterClam,
        #     securityType=self.config.security_type,
        #     name=self.config.universe,
        #     resolution=self.config.data_resolution,
        #     market=self.config.market,
        #     universeSettings=self.UniverseSettings,
        #     selector=self.selector_function,
        # )

        # === 2 - Alpha Models ===
        # self.AddAlpha(RsiAlphaModel())
        self.AddAlpha(SeafoodAlpha(self.Time))

        # === 3 - Portfolio Construction ===
        self.SetPortfolioConstruction(
            MasterCrayfish(
                rebalance=self.UniverseSettings.Resolution,
                portfolioBias=PortfolioBias.LongShort,
                config=self.config,
            )
        )

        # === 4 - Execution ===
        # Master Squid is not compatible with Daily data
        # Default is market order execution in backtest
        if self.config.data_resolution == "minute":
            self.SetExecution(
                MasterSquid(
                    config=self.config,
                )
            )

        # === 5 - Risk Management ===
        self.AddRiskManagement(NullRiskManagementModel())

        install_attributes(self)

    def selector_function(self, data: List[MasterClam]) -> List[Symbol]:
        self.logger.info(
            f"Selector function called with {len(data)} securities :"
            + ", ".join([f"{d.Symbol}" for d in data])
        )

        return [x.Symbol for x in data]

        # Define the selector function for MasterClam universe
        sorted_data = sorted(
            [x for x in data if x["CustomAttribute1"] > 0],
            key=lambda x: x["CustomAttribute2"],
            reverse=True,
        )
        return [x.Symbol for x in sorted_data[:5]]

    def OnData(self, data):
        """Quit the algorithm at 100 bars"""
        if not data:
            self.logger.error("No data received...")
            return

        if getattr(self.config, "backtest_quit_at_bar_cnt", None):

            if hasattr(self, "data_bar_cnt"):
                self.data_bar_cnt += 1
            else:
                self.data_bar_cnt = 1

            if self.data_bar_cnt > self.config.backtest_quit_at_bar_cnt:

                msg = f"********** {self.config.backtest_quit_at_bar_cnt:,} bars received ********** "
                self.logger.critical(msg)
                self.Quit(msg)

        return super().OnData(data)


class SymbolData:

    name = "SymbolData MasterSeafood"

    def __init__(self, algorithm: QCAlgorithm, symbol):

        self.algorithm = algorithm
        self.symbol = symbol
        self.data_resolution = algorithm.UniverseSettings.Resolution

        self.logger = init_logger(name=self.name, indent=0, color="yellow")

        # =========================== Indicators =========================== #

        # SMA 30D of dollar volume = volume * close_price
        # self.dollarVolume = IndicatorExtensions.Times(
        #     algorithm.SMA(self.symbol, 30, Resolution.Daily, Field.Volume),
        #     algorithm.SMA(self.symbol, 30, Resolution.Daily, Field.Close),
        # )

        # RSI
        # self.rsi = algorithm.RSI( self.symbol, 14, MovingAverageType.Simple, Resolution.Daily)

        # RSI-EMA
        # self.rsi_ema = IndicatorExtensions.EMA(self.rsi, 13)
        # self.band1 = IndicatorExtensions.Plus(self.rsi_ema, 8)
        # self.band2 = IndicatorExtensions.Plus(self.rsi_ema, -7)

        # SMA
        self.fast = algorithm.SMA(self.symbol, 5, self.data_resolution, Field.Low)
        self.slow = algorithm.SMA(self.symbol, 60, self.data_resolution, Field.High)

        history = algorithm.History(self.symbol, 60, self.data_resolution)

        if not history.empty:
            for index, bar in history.loc[self.symbol].iterrows():
                self.fast.Update(index, bar.low)
                self.slow.Update(index, bar.high)

            last_row = history.loc[self.symbol].iloc[-1]
            self.open = last_row.open
            self.close = last_row.close
            self.high = last_row.high
            self.low = last_row.low

        # =========================== Consolidators =========================== #
        # self.indicator = SimpleMovingAverage(20)
        # algorithm.WarmUpIndicator(self.symbol, self.indicator)
        ## - not relevant? algorithm.Consolidate(self.symbol, Resolution.Daily, self.DailyBardHandler)
        # self.consolidator = TradeBarConsolidator(1)
        # algorithm.SubscriptionManager.AddConsolidator(symbol, self.consolidator)
        # algorithm.RegisterIndicator(symbol, self.indicator, self.consolidator)

    def dispose(self):
        """Dispose of symbol consolidator data."""
        # self.algorithm.SubscriptionManager.RemoveConsolidator(
        # self.symbol, self.consolidator
        # )
        pass

    def indicatorsAllReady(self):
        """Return True if all indicators are ready"""
        indicators = ["rsi", "rsi_ema", "band1", "band2"]
        # HACK: Disable the above indicators
        indicators = []
        for indicator in indicators:
            if not getattr(self, indicator).IsReady:
                self.logger.warning(f"Indicator {indicator} is not ready")
                return False
        return True


class SeafoodAlpha(AlphaModel):
    """Special seafood alpha of the day."""

    # Assign a unique name to ensure compatible with all `Portfolio Construction` models
    Name = "Alpha MasterSeafood"

    def __init__(self, Time):

        self.symbol_data = Munch()
        self.rebalanceTime = Time

        self.logger = init_logger(name=self.Name, indent=0, color="yellow")

    def Update(self, algorithm: QCAlgorithm, data: Slice) -> List[Insight]:
        """Updates this Alpha model with the latest data from the algorithm.
        This is called each time the algorithm receives data for subscribed securities
        Generate insights on the securities in the universe.

        Valid data bar types: 'Bars', 'QuoteBars', 'FuturesChains' etc.

        """

        self.logger.info(
            f"-------------------- BAR START-TIME: {algorithm.Time} --------------------"
        )
        finclab.lean.portfolio.stats.export_stats_to_log(algorithm=algorithm)
        insights = []

        # TODO: Not working as expected; Need (1) EOD rebalance and (2) portfolio targets when insights are generated
        if algorithm.Time < self.rebalanceTime:
            return insights

        # Iterate over all subscribed symbols
        for symbol, symbol_data in self.symbol_data.items():

            if not data.QuoteBars.ContainsKey(symbol):
                # If missing data -> continue
                self.logger.critical(f"Missing data for {symbol}")
                continue

            if not symbol_data.indicatorsAllReady():
                # If indicators not ready -> continue
                continue

            # Main logic -> Default to return no insights
            insights = self.createUpInsights(symbol, insights, symbol_data, algorithm)
            insights = self.createFlatInsights(symbol, insights, symbol_data, algorithm)
            insights = self.createDownInsights(symbol, insights, symbol_data, algorithm)

        # Set re-balancing to EOD
        self.rebalaceTime = Expiry.EndOfDay(algorithm.Time)

        # Log the insights
        for insight in insights:
            self.logger.info(
                f"Insight: symbol {insight.Symbol}; direction {insight.Direction}; period {insight.Period}; weight {insight.Weight}"
            )
        return insights

    def createUpInsights(
        self, symbol: str, insights: List[Insight], symbol_data: SymbolData, algorithm
    ) -> List[Insight]:
        """Create Price Up insights based on indicators"""
        if symbol_data.slow.Current.Value < symbol_data.fast.Current.Value:
            # Create insight for this signal
            _insight = Insight(
                symbol=symbol,
                period=timedelta(days=30),
                type=InsightType.Price,
                direction=InsightDirection.Up,
                magnitude=None,
                confidence=None,
                sourceModel=None,
                weight=1,
            )

            insights += [_insight]
        return insights

    def createDownInsights(
        self, symbol: str, insights: List[Insight], symbol_data: SymbolData, algorithm
    ) -> List[Insight]:
        """Create Price Down insights based on indicators"""
        if symbol_data.slow.Current.Value >= symbol_data.fast.Current.Value:

            # Create insight for this signal
            _insight = Insight(
                symbol=symbol,
                period=timedelta(days=30),
                type=InsightType.Price,
                direction=InsightDirection.Down,
                magnitude=None,
                confidence=None,
                sourceModel=None,
                weight=1,
            )

            insights += [_insight]
        return insights

    def createFlatInsights(
        self, symbol: str, insights: List[Insight], symbol_data: SymbolData, algorithm
    ) -> List[Insight]:
        """Create Price Flat insights based on indicators"""
        if False:
            # Create insight for this signal
            _insight = Insight(
                symbol=symbol,
                period=timedelta(days=30),
                type=InsightType.Price,
                direction=InsightDirection.Flat,
                magnitude=None,
                confidence=None,
                sourceModel=None,
                weight=1,
            )

            insights += [_insight]

        return insights

    def OnSecuritiesChanged(
        self, algorithm: QCAlgorithm, changes: SecurityChanges
    ) -> None:
        """Security additions and removals are pushed here.
        This can be used for setting up algorithm state.
        """

        for security in changes.AddedSecurities:
            self.logger.warning(f"Added security: {security.Symbol}")
            self.symbol_data[security.Symbol] = SymbolData(
                algorithm,
                security.Symbol,
            )

        for security in changes.RemovedSecurities:
            self.logger.warning(f"Removing security: {security.Symbol}")
            if security.Symbol in self.symbol_data:
                symbol_data = self.symbol_data.pop(security.Symbol, None)
                if symbol_data:
                    symbol_data.dispose()
