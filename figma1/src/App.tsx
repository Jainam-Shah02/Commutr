import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { TransitProvider } from './context/TransitContext';
import Onboarding from './screens/Onboarding';
import LocationPermission from './screens/LocationPermission';
import Home from './screens/Home';
import SearchResults from './screens/SearchResults';
import BusDetails from './screens/BusDetails';
import LiveMap from './screens/LiveMap';
import BoardingScreen from './screens/BoardingScreen';
import RideVerification from './screens/RideVerification';
import Trips from './screens/Trips';
import Alerts from './screens/Alerts';
import Profile from './screens/Profile';
import RouteDetails from './screens/RouteDetails';
import StopDetails from './screens/StopDetails';
import DriverMode from './screens/DriverMode';
import ReportProblem from './screens/ReportProblem';
import PrivacySettings from './screens/PrivacySettings';
import DestinationTracking from './screens/DestinationTracking';

export default function App() {
  return (
    <BrowserRouter>
      <TransitProvider>
        <div className="mobile-frame shadow-xl">
          <Routes>
            <Route path="/" element={<Navigate to="/onboarding" replace />} />
            <Route path="/onboarding" element={<Onboarding />} />
            <Route path="/location-permission" element={<LocationPermission />} />
            <Route path="/home" element={<Home />} />
            <Route path="/search" element={<SearchResults />} />
            <Route path="/bus/:id" element={<BusDetails />} />
            <Route path="/live-map" element={<LiveMap />} />
            <Route path="/board" element={<BoardingScreen />} />
            <Route path="/ride-verification" element={<RideVerification />} />
            <Route path="/trips" element={<Trips />} />
            <Route path="/alerts" element={<Alerts />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/route/:id" element={<RouteDetails />} />
            <Route path="/stop/:id" element={<StopDetails />} />
            <Route path="/driver" element={<DriverMode />} />
            <Route path="/report-problem" element={<ReportProblem />} />
            <Route path="/privacy" element={<PrivacySettings />} />
            <Route path="/destination-tracking" element={<DestinationTracking />} />
          </Routes>
        </div>
      </TransitProvider>
    </BrowserRouter>
  );
}
