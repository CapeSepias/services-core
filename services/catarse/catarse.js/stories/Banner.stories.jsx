import m from 'mithril';
import { storiesOf } from '@storybook/mithril';
import { Banner } from '../legacy/src/components/Banner';

storiesOf('Banner', module)
  .add(
      'Default',
      () => ({ view: () => <Banner /> }),
    );


