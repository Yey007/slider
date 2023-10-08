import { IonContent, IonPage } from "@ionic/react";
import "./Home.css";
import Chart from "../components/Chart";

const Home: React.FC = () => {
  return (
    <IonPage>
      <IonContent fullscreen>
        <Chart curves={[]} />
      </IonContent>
    </IonPage>
  );
};

export default Home;
