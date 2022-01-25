import m from 'mithril';
import { configure } from '@storybook/mithril';

configure(require.context('../stories', true, /\.stories\.jsx$/), module);
