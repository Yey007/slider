import { IonContent, IonPage } from "@ionic/react";
import "./Home.css";
import ChartRender from "../components/ChartRender";
import Chart from "../components/Chart";

const Home: React.FC = () => {
  return (
    <IonPage>
      <IonContent fullscreen>
        <Chart />
      </IonContent>
    </IonPage>
  );
};

export default Home;
