import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import Heading from '@theme/Heading';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <img
          src="/commands_cli/img/logo.webp"
          alt="Commands CLI Logo"
          style={{ height: '160px', marginBottom: '1rem' }}
        />
        <p
          className="hero__subtitle"
          style={{ color: '#025597' }}
        >
          <span className={styles.tagline}>{siteConfig.tagline}</span>
        </p>
        <div>
          <img className={styles.demoImage} src="/commands_cli/img/demo.webp" alt="Demo Preview" />
        </div>
        <div className={styles.buttons}>
          <Link
            className={"button " + styles.getStartedButton}
            to="/docs/intro">
            Get Started
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Commands CLI - Make your CLI commands feel like a breeze">
      <HomepageHeader />
    </Layout>
  );
}
